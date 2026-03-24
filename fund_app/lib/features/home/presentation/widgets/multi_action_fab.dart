import 'dart:ui';
import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';

class MultiActionFab extends StatefulWidget {
  final int currentTabIndex;
  final VoidCallback onAddShared;
  final VoidCallback onAddPersonal;
  final VoidCallback onAddDeposit;
  final VoidCallback onAddTrip;

  const MultiActionFab({
    super.key,
    required this.currentTabIndex,
    required this.onAddShared,
    required this.onAddPersonal,
    required this.onAddDeposit,
    required this.onAddTrip,
  });

  @override
  State<MultiActionFab> createState() => _MultiActionFabState();
}

class _MultiActionFabState extends State<MultiActionFab> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  // late AnimationController _controller;
  late AnimateIconController _controller;

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _controller = AnimateIconController();
  }

  void _toggle() => setState(() {
    _isOpen = !_isOpen;
    // _isOpen ? _controller.forward() : _controller.reverse();
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full screen blur layer
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),
        
        // FAB and Options
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isOpen) ..._buildContextualButtons(),
              const SizedBox(height: 16),
              // Main Toggle Button (Dark Circle with X)
              SizedBox(
                width: 60,
                height: 60,
                child: FloatingActionButton(
                  onPressed: _toggle,
                  backgroundColor: const Color(0xFF13161F), // Very dark navy/black
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: AnimateIcons(
                    startIcon: Icons.add,
                    endIcon: Icons.close,
                    size: 50.0,
                    onStartIconPress: () {
                      print("Clicked on Add Icon");
                      return true;
                    },
                    onEndIconPress: () {
                      print("Clicked on Close Icon");
                      return true;
                    },
                    duration: Duration(milliseconds: 500),
                    startIconColor: Colors.white,

                    clockwise: false,
                    controller: _controller,
                  ),
                  // child: AnimatedIcon(
                  //   icon: AnimatedIcons.,
                  //   progress: _controller,
                  //   color: Colors.white,
                  //   size: 28,
                  // ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildContextualButtons() {
    final List<Widget> buttons = [];

    if (widget.currentTabIndex == 2) {
      buttons.add(_buildUnifiedOption("New Trip", Icons.map_outlined, widget.onAddTrip));
      buttons.add(const SizedBox(height: 12));
      buttons.add(_buildUnifiedOption("Shared Expense", Icons.shopping_cart_outlined, widget.onAddShared));
    } else if (widget.currentTabIndex == 1) {
      buttons.add(_buildUnifiedOption("Deposit", Icons.south_west_outlined, widget.onAddDeposit));
      buttons.add(const SizedBox(height: 12));
      buttons.add(_buildUnifiedOption("Personal Expense", Icons.account_balance_wallet_outlined, widget.onAddPersonal));
    } else {
      // Home tab shows all
      buttons.add(_buildUnifiedOption("Deposit", Icons.south_west_outlined, widget.onAddDeposit));
      buttons.add(const SizedBox(height: 12));
      buttons.add(_buildUnifiedOption("Shared Expense", Icons.shopping_cart_outlined, widget.onAddShared));
      buttons.add(const SizedBox(height: 12));
      buttons.add(_buildUnifiedOption("Personal Expense", Icons.account_balance_wallet_outlined, widget.onAddPersonal));
    }

    return buttons.reversed.toList();
  }

  // Unified Capsule UI
  Widget _buildUnifiedOption(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        _toggle();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // Pill shape
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 16), // Gap between text and icon
            Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30), // Pill shape
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon, color: Colors.black, size: 20),
              )
            ),
          ],
        ),
      ),
    );
  }
}