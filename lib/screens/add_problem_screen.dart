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
  final tagController = TextEditingController();
  
  String status = 'Pending';
  bool isLoading = false;
  List<String> tags = [];

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

    setState(() => isLoading = true);

    try {
      final problem = Problem(
        id: '',
        userId: '',
        title: titleController.text.trim(),
        url: urlController.text.trim(),
        platform: platformController.text.trim(),
        tags: tags,
        status: status,
        createdAt: DateTime.now(),
      );

      await addProblem(problem);
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Problem added'), backgroundColor: Colors.green));
      
      await Future.delayed(Duration(milliseconds: 800));
      Navigator.pop(context, true);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color getStatusColor(String s) {
    if (s == 'Solved') return Colors.green.shade800;
    if (s == 'Attempt') return Colors.blue.shade800;
    return Colors.grey.shade800;
  }

  void addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      setState(() {
        tags.add(tag);
        tagController.clear();
      });
    }
  }

  void removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    urlController.dispose();
    platformController.dispose();
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Add Problem', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Text('Problem Title *', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(height: 8),
                TextFormField(
                  controller: titleController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g., Two Sum',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade700)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade700)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue)),
                    fillColor: Colors.grey.shade900,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                SizedBox(height: 20),
                
                Text('Problem URL *', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(height: 8),
                TextFormField(
                  controller: urlController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: 'https://leetcode.com/problems/two-sum/',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade700)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade700)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue)),
                    fillColor: Colors.grey.shade900,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                SizedBox(height: 20),
                
                Text('Platform Name *', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(height: 8),
                TextFormField(
                  controller: platformController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g., LeetCode, Codeforces, etc.',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade700)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade700)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue)),
                    fillColor: Colors.grey.shade900,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                SizedBox(height: 20),
                
                Text('Tags (Optional)', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: tagController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g., DP, Graph, Math',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade700)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade700)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue)),
                          fillColor: Colors.grey.shade900,
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.blue),
                      onPressed: addTag,
                      tooltip: 'Add Tag',
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      return Chip(
                        label: Text(tag, style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.grey.shade800,
                        deleteIcon: Icon(Icons.close, size: 16, color: Colors.white),
                        onDeleted: () => removeTag(tag),
                      );
                    }).toList(),
                  ),
                SizedBox(height: 20),
                
                Text('Status *', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
                SizedBox(height: 8),
                Row(
                  children: ['Pending', 'Attempt', 'Solved'].map((s) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: ChoiceChip(
                          label: Text(s, style: TextStyle(
                            color: status == s ? Colors.white : Colors.grey.shade300,
                            fontWeight: status == s ? FontWeight.w600 : FontWeight.normal
                          )),
                          selected: status == s,
                          onSelected: (selected) {
                            setState(() {
                              status = s;
                            });
                          },
                          selectedColor: getStatusColor(s),
                          backgroundColor: Colors.grey.shade900,
                          side: BorderSide.none,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 32),
                
                SimpleButton(text: 'Add Problem', onPressed: save, loading: isLoading),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}