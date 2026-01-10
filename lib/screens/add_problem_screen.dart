import 'package:flutter/material.dart';
import '../database.dart';
import '../models/problem.dart';
import '../widgets/simple_button.dart';

class AddProblemScreen extends StatefulWidget {
  @override
  _AddProblemScreenState createState() => _AddProblemScreenState();
}

class _AddProblemScreenState extends State<AddProblemScreen> {
  final titleController = TextEditingController();
  final urlController = TextEditingController();
  final platformController = TextEditingController();
  final notesController = TextEditingController();
  
  String difficulty = 'Medium';
  String status = 'Pending';
  DateTime date = DateTime.now();
  bool loading = false;

  List<String> diffs = ['Easy', 'Medium', 'Hard'];

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != date) {
      setState(() => date = picked);
    }
  }

  Future<void> save() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Title required'), backgroundColor: Colors.red));
      return;
    }
    if (urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('URL required'), backgroundColor: Colors.red));
      return;
    }
    if (platformController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Platform required'), backgroundColor: Colors.red));
      return;
    }

    setState(() => loading = true);

    try {
      final problem = Problem(
        id: '',
        userId: '',
        title: titleController.text.trim(),
        url: urlController.text.trim(),
        platform: platformController.text.trim(),
        difficulty: difficulty,
        status: status,
        date: date,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
        createdAt: DateTime.now(),
      );

      await addProblem(problem);
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Problem added'), backgroundColor: Colors.green));
      
      await Future.delayed(Duration(milliseconds: 800));
      Navigator.pop(context, true);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => loading = false);
    }
  }

  Color getStatusColor(String s) {
    if (s == 'Solved') return Colors.green.shade100;
    if (s == 'Attempt') return Colors.blue.shade100;
    return Colors.grey.shade100;
  }

  Color getDiffColor(String d) {
    if (d == 'Easy') return Colors.green;
    if (d == 'Medium') return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    titleController.dispose();
    urlController.dispose();
    platformController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Problem'),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text('Problem Title *', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'e.g., Two Sum',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            SizedBox(height: 20),
            
            Text('Problem URL *', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            TextFormField(
              controller: urlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'https://leetcode.com/problems/two-sum/',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            SizedBox(height: 20),
            
            Text('Platform Name *', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            TextFormField(
              controller: platformController,
              decoration: InputDecoration(
                hintText: 'e.g., LeetCode, Codeforces, etc.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            SizedBox(height: 20),
            
            Text('Difficulty *', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: difficulty,
                  isExpanded: true,
                  items: diffs.map((d) {
                    return DropdownMenuItem<String>(
                      value: d,
                      child: Row(
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: getDiffColor(d), shape: BoxShape.circle)),
                          SizedBox(width: 8),
                          Text(d),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => difficulty = value!),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            Text('Status *', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Row(
              children: ['Pending', 'Attempt', 'Solved'].map((s) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: ChoiceChip(
                      label: Text(s),
                      selected: status == s,
                      onSelected: (selected) => setState(() => status = s),
                      selectedColor: getStatusColor(s),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            
            Text('Date Solved/Attempted *', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            GestureDetector(
              onTap: pickDate,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                    SizedBox(width: 12),
                    Text('${date.day}/${date.month}/${date.year}', style: TextStyle(fontSize: 16)),
                    Spacer(),
                    Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            Text('Notes (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            TextFormField(
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Any thoughts...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue)),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
            SizedBox(height: 32),
            
            Text('* Required fields', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
            SizedBox(height: 16),
            
            SimpleButton(text: 'Add Problem', onPressed: save, loading: loading),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}