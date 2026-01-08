import 'package:flutter/material.dart';
import '../models/problem.dart';
import '../services/problem_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddProblemScreen extends StatefulWidget {
  @override
  _AddProblemScreenState createState() => _AddProblemScreenState(); 
}

class _AddProblemScreenState extends State<AddProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _platformController = TextEditingController();
  final _notesController = TextEditingController();
  
  final ProblemService problemService = ProblemService();
  
  String difficulty = 'Medium';
  String status = 'Pending';
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  List<String> difficulties = ['Easy', 'Medium', 'Hard'];

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> submitProblem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final problem = Problem(
        id: '',
        userId: '',
        title: _titleController.text.trim(),
        problemUrl: _urlController.text.trim(),
        platform: _platformController.text.trim(),
        difficulty: difficulty,
        status: status,
        dateSolved: selectedDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now(),
      );

      await problemService.addProblem(problem); // add problem
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Problem added successfully!'), backgroundColor: Colors.green),
      );
      
      await Future.delayed(Duration(milliseconds: 1000));
      Navigator.pop(context, true);
      
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Solved': return Colors.green.shade100;
      case 'Attempt': return Colors.blue.shade100;
      default: return Colors.grey.shade100;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _platformController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Problem'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text('Problem Title *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              CustomTextField(
                controller: _titleController,
                hintText: 'e.g., Two Sum',
                validator: (value) => Validators.validateRequired(value, 'Problem title'),
              ),
              SizedBox(height: 20),
              Text('Problem URL *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              CustomTextField(
                controller: _urlController,
                hintText: 'https://leetcode.com/problems/two-sum/',
                keyboardType: TextInputType.url,
                validator: Validators.validateUrl,
              ),
              SizedBox(height: 20),
              Text('Platform Name *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              CustomTextField(
                controller: _platformController,
                hintText: 'e.g., LeetCode, Codeforces, CodeChef, HackerRank, etc.',
                validator: (value) => Validators.validateRequired(value, 'Platform name'),
              ),
              SizedBox(height: 20),
              Text('Difficulty *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: difficulty,
                    isExpanded: true,
                    items: difficulties.map((difficulty) {
                      Color color;
                      switch (difficulty) {
                        case 'Easy': color = Colors.green; break;
                        case 'Medium': color = Colors.orange; break;
                        default: color = Colors.red;
                      }
                      
                      return DropdownMenuItem<String>(
                        value: difficulty,
                        child: Row(
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                            SizedBox(width: 8),
                            Text(difficulty),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => difficulty = value!),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Status *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              Row(
                children: ['Pending', 'Attempt', 'Solved'].map((statusOption) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: ChoiceChip(
                        label: Text(statusOption),
                        selected: status == statusOption,
                        onSelected: (selected) => setState(() => status = statusOption),
                        selectedColor: getStatusColor(statusOption),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text('Date Solved/Attempted *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => selectDate(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                      SizedBox(width: 12),
                      Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', style: TextStyle(fontSize: 16)),
                      Spacer(),
                      Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Notes (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Any thoughts or insights about this problem...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue)),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 32),
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('* Required fields', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
              ),
              CustomButton(text: 'Add Problem', onPressed: submitProblem, isLoading: isLoading),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}