import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(
    MaterialApp(
      home: PetNameInputScreen(),
    ),
  );
}

// Screen for entering the pet's name
class PetNameInputScreen extends StatefulWidget {
  @override
  _PetNameInputScreenState createState() => _PetNameInputScreenState();
}

class _PetNameInputScreenState extends State<PetNameInputScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _navigateToDigitalPetApp(BuildContext context) {
    if (_nameController.text.trim().isEmpty) {
      // Show an error if the name is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a name for your pet!')),
      );
    } else {
      // Navigate to the main app screen with the pet's name
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DigitalPetApp(petName: _nameController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Name Your Pet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Enter your pet\'s name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToDigitalPetApp(context),
              child: Text('Confirm Name'),
            ),
          ],
        ),
      ),
    );
  }
}

// Main app screen
class DigitalPetApp extends StatefulWidget {
  final String petName;

  DigitalPetApp({required this.petName});

  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  int happinessLevel = 50;
  int hungerLevel = 50;
  int _energyLevel = 100; // New energy level state variable
  Timer? _hungerTimer; // Timer for automatic hunger increase
  Timer? _winTimer; // Timer to track happiness above 80
  Duration _winDuration = Duration(minutes: 3); // Duration for win condition
  bool _gameOver = false; // Track if the game is over
  bool _gameWon = false; // Track if the game is won

  // Activity selection variables
  String? _selectedActivity;
  final List<String> _activities = [
    'Play',
    'Feed',
    'Nap',
    'Exercise',
  ];

  @override
  void initState() {
    super.initState();
    // Start the timer when the app starts
    _startHungerTimer();
  }

  @override
  void dispose() {
    // Cancel the timers when the app is disposed
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    super.dispose();
  }

  // Function to start the hunger timer
  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100); // Increase hunger by 5 every 30 seconds
        _updateHappiness(); // Update happiness based on hunger level
        _checkLossCondition(); // Check if the player has lost
      });
    });
  }

  // Function to check the win condition
  void _checkWinCondition() {
    if (happinessLevel > 80 && !_gameWon) {
      // Start the win timer if happiness is above 80
      _winTimer ??= Timer(_winDuration, () {
        setState(() {
          _gameWon = true; // Player wins
          _gameOver = true; // End the game
        });
      });
    } else if (happinessLevel <= 80) {
      // Reset the win timer if happiness drops below 80
      _winTimer?.cancel();
      _winTimer = null;
    }
  }

  // Function to check the loss condition
  void _checkLossCondition() {
    if (hungerLevel >= 100 && happinessLevel <= 10 && !_gameOver) {
      setState(() {
        _gameOver = true; // Player loses
      });
    }
  }

  // Function to determine the pet's color based on happiness level
  Color _getPetColor() {
    if (happinessLevel > 70) {
      return Colors.green; // Happy
    } else if (happinessLevel >= 30 && happinessLevel <= 70) {
      return Colors.yellow; // Neutral
    } else {
      return Colors.red; // Unhappy
    }
  }

  // Function to determine the pet's mood based on happiness level
  String _getPetMood() {
    if (happinessLevel > 70) {
      return 'Happy 😊';
    } else if (happinessLevel >= 30 && happinessLevel <= 70) {
      return 'Neutral 😐';
    } else {
      return 'Unhappy 😞';
    }
  }

  // Function to confirm the selected activity and update pet state
  void _confirmActivity() {
    if (_selectedActivity == null) return;

    setState(() {
      switch (_selectedActivity) {
        case 'Play':
          happinessLevel = (happinessLevel + 10).clamp(0, 100);
          _energyLevel = (_energyLevel - 10).clamp(0, 100);
          _updateHunger();
          break;
        case 'Feed':
          hungerLevel = (hungerLevel - 10).clamp(0, 100);
          _energyLevel = (_energyLevel + 5).clamp(0, 100);
          _updateHappiness();
          break;
        case 'Nap':
          _energyLevel = (_energyLevel + 20).clamp(0, 100);
          break;
        case 'Exercise':
          happinessLevel = (happinessLevel + 5).clamp(0, 100);
          _energyLevel = (_energyLevel - 15).clamp(0, 100);
          hungerLevel = (hungerLevel + 5).clamp(0, 100);
          break;
      }
      _checkWinCondition(); // Check if the player has won
    });
  }

  // Update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
    _checkWinCondition(); // Check if the player has won
  }

  // Increase hunger level slightly when playing with the pet
  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
    _checkLossCondition(); // Check if the player has lost
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_gameOver)
              Text(
                _gameWon ? 'You Win! 🎉' : 'Game Over! 😢',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            if (!_gameOver) ...[
              // Pet representation with dynamic color
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _getPetColor(), // Dynamic color based on happiness
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/catbird-removebg-preview.png', // Path to your image in the assets folder
                    width: 80, // Adjust the size as needed
                    height: 80,
                    fit: BoxFit.cover, // Ensure the image fits within the container
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              // Pet mood indicator
              Text(
                'Mood: ${_getPetMood()}', // Display mood text and emoji
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              Text(
                'Name: ${widget.petName}', // Display the custom pet name
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              Text(
                'Happiness Level: $happinessLevel',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              Text(
                'Hunger Level: $hungerLevel',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              // Energy Bar Widget
              Text(
                'Energy Level: $_energyLevel',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 8.0),
              LinearProgressIndicator(
                value: _energyLevel / 100, // Normalize energy level to a value between 0 and 1
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 32.0),
              // Activity Selection Dropdown
              DropdownButton<String>(
                value: _selectedActivity,
                hint: Text('Select an activity'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedActivity = newValue;
                  });
                },
                items: _activities.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _confirmActivity,
                child: Text('Confirm Activity'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}