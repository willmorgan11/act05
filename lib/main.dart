import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int energyLevel = 100;
  // name input controller
  final TextEditingController _nameController = TextEditingController();
  // timers
  Timer? _hungerTimer;    // auto-increases hunger every 30 seconds
  Timer? _winTimer;       // tracks how long happiness > 80
  int _happySeconds = 0;
  bool _gameOver = false;
  bool _gameWon = false;
  // hunger timer
  @override
  void initState() {
    super.initState();
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 10).clamp(0, 100);
      });
    });
    // win timer
    _winTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_gameOver && !_gameWon) {
        setState(() {
          if (happinessLevel > 80) {
            _happySeconds++;
            if (_happySeconds >= 180) { // 3 minutes = 180 seconds for win
              _gameWon = true;
              _winTimer?.cancel();
              _hungerTimer?.cancel();
            }
          } else {
            _happySeconds = 0; // reset if happiness drops below 80
          }
        });
      }
    });
  }
  // cancel timers and dispose controllers
  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  // dynamic pet color change
  Color _moodColor() {
    if (happinessLevel > 70) return Colors.green;
    if (happinessLevel >= 30) return Colors.yellow;
    return Colors.red;
  }

  // pet mood indicator
  String _moodText() {
  if (happinessLevel > 70) return "Happy 😄";
  if (happinessLevel >= 30) return "Neutral 😐";
  return "Unhappy 😢";
  }

  // win/loss
  void _checkConditions() {
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _gameOver = true;
      _hungerTimer?.cancel();
      _winTimer?.cancel();
    }
  }
  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      energyLevel = (energyLevel - 10).clamp(0, 100); // playing uses energy
      _updateHunger();
      _checkConditions();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      energyLevel = (energyLevel + 5).clamp(0, 100); // eating restores a little energy
      _updateHappiness();
      _checkConditions();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel >= 100) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  // pet name customization
  void _setPetName() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        petName = _nameController.text.trim();
        _nameController.clear();
      });
    }
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
            // win / loss text
                        if (_gameWon)
              Text('🏆 YOU WIN! Your pet is thriving!',
              style: TextStyle(
                fontSize: 22,
                color: Colors.green, 
                fontWeight: FontWeight.bold)),
            if (_gameOver)
              Text('💀 GAME OVER! Your pet is too hungry!',
              style: TextStyle(
                fontSize: 22, 
                color: Colors.red, 
                fontWeight: FontWeight.bold)),
            // custom pet name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter pet name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 4.0),
            ElevatedButton(
              onPressed: _setPetName,
              child: Text('Set Name'),
            ),
            SizedBox(height: 4.0),
            Text('Name: $petName', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),
            // color filter for pet image
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                _moodColor(),
                BlendMode.modulate,
              ),
              child: Image.asset(
                'assets/image2.png',
                width: 200,
                height: 200,
              ),
            ),
            SizedBox(height: 8.0),
            // mood indicator
            Text(_moodText(), style: TextStyle(fontSize: 24.0)),
            SizedBox(height: 16.0),
            Text('Happiness Level: $happinessLevel', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),
            Text('Hunger Level: $hungerLevel', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),
            Text('Energy Level: $energyLevel', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: LinearProgressIndicator(
                value: energyLevel / 100,   // must be between 0.0 and 1.0
                minHeight: 16,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  energyLevel > 60 ? Colors.blue :
                  energyLevel > 30 ? Colors.orange :
                  Colors.red,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _playWithPet,
              child: Text('Play with Your Pet'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _feedPet,
              child: Text('Feed Your Pet'),
            ),
          ],
        ),
      ),
    );
  }
}