import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_number/utils/constants.dart';
import 'package:audioplayers/audioplayers.dart';

class InputSection extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;
  final bool isEnabled;
  final Function(String) onSubmitted;

  const InputSection({
    super.key,
    required this.controller,
    required this.isDark,
    required this.isEnabled,
    required this.onSubmitted,
  });

  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> with TickerProviderStateMixin {
  String displayNumber = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, AnimationController> _buttonControllers = {};
  
  // Animation for the display
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    displayNumber = widget.controller.text;
    widget.controller.addListener(_updateDisplayNumber);
    
    // Initialize display animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Initialize button animations
    for (int i = 0; i <= 9; i++) {
      _buttonControllers[i.toString()] = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this,
      );
    }
    _buttonControllers['clear'] = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _buttonControllers['delete'] = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  void _updateDisplayNumber() {
    setState(() {
      displayNumber = widget.controller.text;
    });
  }

  Future<void> _playSound(String type) async {
    try {
      switch (type) {
        case 'number':
          await _audioPlayer.setSource(AssetSource('sounds/click.mp3'));
          break;
        case 'clear':
          await _audioPlayer.setSource(AssetSource('sounds/clear.mp3'));
          break;
        case 'delete':
          await _audioPlayer.setSource(AssetSource('sounds/delete.mp3'));
          break;
        case 'error':
          await _audioPlayer.setSource(AssetSource('sounds/error.mp3'));
          break;
      }
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _animateButton(String key) {
    _buttonControllers[key]?.forward().then((_) {
      _buttonControllers[key]?.reverse();
    });
  }

  void _onNumberPress(String number) async {
    if (!widget.isEnabled) {
      _playSound('error');
      return;
    }
    
    if (displayNumber.length < 3) {
      _animateButton(number);
      HapticFeedback.lightImpact();
      await _playSound('number');
      
      setState(() {
        displayNumber += number;
        widget.controller.text = displayNumber;
      });
      
      _scaleController.forward().then((_) => _scaleController.reverse());
    } else {
      _playSound('error');
    }
  }

  void _onDelete() async {
    if (displayNumber.isNotEmpty) {
      _animateButton('delete');
      HapticFeedback.mediumImpact();
      await _playSound('delete');
      
      setState(() {
        displayNumber = displayNumber.substring(0, displayNumber.length - 1);
        widget.controller.text = displayNumber;
      });
    }
  }

  void _onClear() async {
    if (displayNumber.isNotEmpty) {
      _animateButton('clear');
      HapticFeedback.heavyImpact();
      await _playSound('clear');
      
      setState(() {
        displayNumber = '';
        widget.controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display current input
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.medium,
              vertical: AppPadding.medium,
            ),
            decoration: BoxDecoration(
              color: widget.isDark ? darkCardColor : cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (widget.isDark ? darkPrimaryColor : primaryColor)
                    .withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              displayNumber.isEmpty ? '?' : displayNumber,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: AppPadding.medium),
        // Number pad
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            // Numbers 1-9
            for (int i = 1; i <= 9; i++)
              _buildAnimatedNumberButton(i.toString()),
            // Clear button
            _buildAnimatedActionButton(
              key: 'clear',
              icon: Icons.clear_all,
              onTap: _onClear,
              color: Colors.orange,
            ),
            // Number 0
            _buildAnimatedNumberButton('0'),
            // Delete button
            _buildAnimatedActionButton(
              key: 'delete',
              icon: Icons.backspace,
              onTap: _onDelete,
              color: Colors.red,
            ),
          ],
        ),
        const SizedBox(height: AppPadding.medium),
        // Submit button
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildAnimatedNumberButton(String number) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.95).animate(
        _buttonControllers[number]!,
      ),
      child: _buildNumberButton(number),
    );
  }

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberPress(number),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: (widget.isDark ? darkPrimaryColor : primaryColor)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (widget.isDark ? darkPrimaryColor : primaryColor)
                  .withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.isEnabled
                    ? (widget.isDark ? Colors.white : primaryColor)
                    : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedActionButton({
    required String key,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.95).animate(
        _buttonControllers[key]!,
      ),
      child: _buildActionButton(icon: icon, onTap: onTap, color: color),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: widget.isEnabled ? color : Colors.grey,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.isEnabled && displayNumber.isNotEmpty
            ? () => widget.onSubmitted(displayNumber)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isDark ? darkPrimaryColor : primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppPadding.medium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          'Guess',
          style: AppTextStyles.button.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateDisplayNumber);
    _audioPlayer.dispose();
    _scaleController.dispose();
    for (var controller in _buttonControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}