import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auction_product.dart';

class AuctionProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<AuctionProduct> _activeAuctions = [];
  bool _isLoading = false;
  String? _errorMessage;
  RealtimeChannel? _auctionChannel; // Keep track of the channel

  List<AuctionProduct> get activeAuctions => _activeAuctions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuctionProvider() {
    fetchActiveAuctions();
    _listenToAuctionChanges(); // Listen for real-time updates
  }

  Future<void> fetchActiveAuctions() async {
    // Prevent unnecessary fetches if already loading
    if (_isLoading) return;
    
    _isLoading = true;
    _errorMessage = null;
    // Notify listeners only if starting the load
    notifyListeners();

    try {
      final response = await _supabase
          .from('auctions')
          .select() // Consider selecting specific columns needed for AuctionProduct.fromJson
          .eq('status', 'active')
          .order('created_at', ascending: false);

       // No need to cast response, Supabase client returns List<Map<String, dynamic>> directly
       _activeAuctions = response
           .map((data) => AuctionProduct.fromJson(data))
           .toList();

    } catch (error) {
      print('Error fetching active auctions: $error');
      _errorMessage = 'Failed to load auctions: ${error.toString()}';
      _activeAuctions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new auction locally (called after successful post)
  void addAuctionLocally(AuctionProduct newAuction) {
     // Avoid duplicates if already added via real-time
     if (!_activeAuctions.any((a) => a.id == newAuction.id)) {
        _activeAuctions.insert(0, newAuction); // Add to the beginning
        notifyListeners();
     }
  }

  // Corrected method to listen to real-time changes
  void _listenToAuctionChanges() {
    // Ensure channel is created only once
    _auctionChannel ??= _supabase.channel('public:auctions');

    _auctionChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all, // Listen to all events (INSERT, UPDATE, DELETE)
          schema: 'public',
          table: 'auctions',
          callback: (payload) {
            print('Auction change received: ${payload.toString()}'); // Debug log
            
            // More robust handling: Check payload type and update list accordingly
            // For simplicity now, just re-fetch
            // TODO: Implement more granular updates based on payload event type
            // Example: If payload.eventType == PostgresChangeEvent.insert -> add locally
            // Example: If payload.eventType == PostgresChangeEvent.delete -> remove locally
            // Example: If payload.eventType == PostgresChangeEvent.update -> update locally
            fetchActiveAuctions(); 
          },
        );
        // .subscribe((status, [error]) {
        //    // Optional: Handle subscription status changes (e.g., disconnected, error)
        //    if (status == RealtimeSubscribeStatus.subscribed) {
        //      print('Auction channel subscribed successfully');
        //    } else if (status == RealtimeSubscribeStatus.subscribeError || error != null) {
        //       print('Error subscribing to auction channel: $error');
        //       _errorMessage = "Realtime connection error. Some updates might be missed.";
        //       notifyListeners();
        //    }
        // });
  }

  @override
  void dispose() {
    // Unsubscribe and remove the channel when the provider is disposed
    if (_auctionChannel != null) {
       _supabase.removeChannel(_auctionChannel!); 
    }
    super.dispose();
  }

} 