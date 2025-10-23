import 'package:flutter/material.dart';

void main() => runApp(const BMICalculatorApp());

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(useMaterial3: true),
      home: const BMIScreen(),
    );
  }
}

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final feetController = TextEditingController();
  final inchController = TextEditingController();

  String weightUnit = 'kg';
  String heightUnit = 'cm';

  double? bmi;
  String? category;
  Color? categoryColor;

  void calculateBMI() {
    double? weight = double.tryParse(weightController.text);
    double? height = double.tryParse(heightController.text);
    double? feet = double.tryParse(feetController.text);
    double? inch = double.tryParse(inchController.text);

    if (weight == null || weight <= 0) {
      showError('Enter valid weight');
      return;
    }

    double weightKg = weightUnit == 'lb' ? weight * 0.453592 : weight;
    double heightM;

    if (heightUnit == 'cm') {
      if (height == null || height <= 0) {
        showError('Enter valid height in cm');
        return;
      }
      heightM = height / 100;
    } else if (heightUnit == 'm') {
      if (height == null || height <= 0) {
        showError('Enter valid height in meters');
        return;
      }
      heightM = height;
    } else {
      if (feet == null || feet < 0 || inch == null || inch < 0) {
        showError('Enter valid feet/inch');
        return;
      }

      // UX: auto carry inches ≥ 12
      if (inch >= 12) {
        feet += inch ~/ 12;
        inch = inch % 12;
      }

      double totalInches = feet * 12 + inch;
      heightM = totalInches * 0.0254;
    }

    double result = weightKg / (heightM * heightM);
    setState(() {
      bmi = double.parse(result.toStringAsFixed(1));
      final info = getBMICategory(bmi!);
      category = info['label'];
      categoryColor = info['color'];
    });
  }

  Map<String, dynamic> getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return {'label': 'Underweight', 'color': Colors.blue};
    } else if (bmi < 25.0) {
      return {'label': 'Normal', 'color': Colors.green};
    } else if (bmi < 30.0) {
      return {'label': 'Overweight', 'color': Colors.orange};
    } else {
      return {'label': 'Obese', 'color': Colors.red};
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Weight Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Weight'),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: weightUnit,
                  items: ['kg', 'lb']
                      .map(
                        (unit) =>
                            DropdownMenuItem(value: unit, child: Text(unit)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => weightUnit = value!),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Height Input
            Row(
              children: [
                const Text('Height Unit:'),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: heightUnit,
                  items: ['cm', 'm', 'ft+in']
                      .map(
                        (unit) =>
                            DropdownMenuItem(value: unit, child: Text(unit)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => heightUnit = value!),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (heightUnit == 'ft+in') ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: feetController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Feet'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: inchController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Inches'),
                    ),
                  ),
                ],
              ),
            ] else
              TextField(
                controller: heightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Height in $heightUnit'),
              ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: calculateBMI,
              child: const Text('Calculate BMI'),
            ),

            const SizedBox(height: 24),
            if (bmi != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Your BMI: $bmi',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(category!),
                        backgroundColor: categoryColor,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
