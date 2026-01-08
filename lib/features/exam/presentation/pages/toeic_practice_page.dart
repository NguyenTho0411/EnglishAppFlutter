// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../domain/entities/toeic_part.dart';
// import '../../../authentication/presentation/blocs/auth/auth_bloc.dart';
// import '../cubits/exam_cubit.dart';

// // Page riêng cho TOEIC Practice
// class ToeicPracticePage extends StatefulWidget {
//   const ToeicPracticePage({Key? key}) : super(key: key);

//   @override
//   State<ToeicPracticePage> createState() => _ToeicPracticePageState();
// }

// class _ToeicPracticePageState extends State<ToeicPracticePage> {
//   String _selectedSection = 'full';

// @override
//   void initState() {
//     super.initState(); // LUÔN gọi super.initState() đầu tiên ở đây
    
//     // Gọi API/Cubit sau khi frame đầu tiên được dựng xong
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         final authState = context.read<AuthBloc>().state;
//         if (authState.user != null) {
//           context.read<ExamCubit>().getToeicStatistics(authState.user!.uid);
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('TOEIC Practice'),
//         centerTitle: true,
//         backgroundColor: Colors.green,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Section Selector
//             _buildSectionSelector(),
//             const SizedBox(height: 24),
            
//             // Practice by Part
//             const Text(
//               'Practice by Part',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
            
//             if (_selectedSection == 'listening' || _selectedSection == 'full')
//               _buildListeningParts(),
            
//             if (_selectedSection == 'reading' || _selectedSection == 'full')
//               _buildReadingParts(),
            
//             const SizedBox(height: 24),
            
//             // Full Test
//             const Text(
//               'Full Test',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             _buildFullTestCard(),
            
//             const SizedBox(height: 24),
            
//             // Your Progress
//             const Text(
//               'Your Progress',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             _buildProgressCard(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionSelector() {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _SectionButton(
//               title: 'Full Test',
//               isSelected: _selectedSection == 'full',
//               onTap: () => setState(() => _selectedSection = 'full'),
//               color: Colors.green,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: _SectionButton(
//               title: 'Listening',
//               isSelected: _selectedSection == 'listening',
//               onTap: () => setState(() => _selectedSection = 'listening'),
//               color: Colors.orange,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: _SectionButton(
//               title: 'Reading',
//               isSelected: _selectedSection == 'reading',
//               onTap: () => setState(() => _selectedSection = 'reading'),
//               color: Colors.blue,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildListeningParts() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Listening (100 questions)',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 12),
//         GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: 2,
//           mainAxisSpacing: 12,
//           crossAxisSpacing: 12,
//           childAspectRatio: 1.3,
//           children: [
//             _ToeicPartCard(
//               partNumber: 1,
//               title: 'Photographs',
//               description: '6 questions',
//               icon: Icons.photo_camera,
//               color: Colors.orange,
//               onTap: () {
//                 _navigateToToeicPart(ToeicPart.part1);
//               },
//             ),
//             _ToeicPartCard(
//               partNumber: 2,
//               title: 'Question-Response',
//               description: '25 questions',
//               icon: Icons.question_answer,
//               color: Colors.deepOrange,
//               onTap: () {
//                 _navigateToToeicPart(ToeicPart.part2);
//               },
//             ),
//             _ToeicPartCard(
//               partNumber: 3,
//               title: 'Conversations',
//               description: '39 questions',
//               icon: Icons.people,
//               color: Colors.orange[700]!,
//               onTap: () {
//                 _navigateToToeicPart(ToeicPart.part3);
//               },
//             ),
//             _ToeicPartCard(
//               partNumber: 4,
//               title: 'Talks',
//               description: '30 questions',
//               icon: Icons.record_voice_over,
//               color: Colors.amber,
//               onTap: () {
//                 _navigateToToeicPart(ToeicPart.part4);
//               },
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
//       ],
//     );
//   }

//   void _navigateToToeicPart(ToeicPart part) {
//     // TODO: Implement navigation to specific TOEIC part practice
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Opening ${part.title} practice...'),
//         duration: const Duration(seconds: 1),
//       ),
//     );
//   }

//   Widget _buildReadingParts() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Reading (100 questions)',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 12),
//         GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: 2,
//           mainAxisSpacing: 12,
//           crossAxisSpacing: 12,
//           childAspectRatio: 1.3,
//           children: [
//             _ToeicPartCard(
//               partNumber: 5,
//               title: 'Incomplete Sentences',
//               description: '30 questions',
//               icon: Icons.text_fields,
//               color: Colors.blue,
//               onTap: () {
//                 // Navigate to Part 5 practice
//               },
//             ),
//             _ToeicPartCard(
//               partNumber: 6,
//               title: 'Text Completion',
//               description: '16 questions',
//               icon: Icons.article,
//               color: Colors.lightBlue,
//               onTap: () {
//                 // Navigate to Part 6 practice
//               },
//             ),
//             _ToeicPartCard(
//               partNumber: 7,
//               title: 'Reading Comprehension',
//               description: '54 questions',
//               icon: Icons.menu_book,
//               color: Colors.indigo,
//               onTap: () {
//                 // Navigate to Part 7 practice
//               },
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
//       ],
//     );
//   }

//   Widget _buildFullTestCard() {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Colors.green[400]!, Colors.green[600]!],
//           ),
//         ),
//         child: InkWell(
//           onTap: () {
//             // Navigate to full test selection
//           },
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 Icon(Icons.assignment, size: 48, color: Colors.white),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Complete TOEIC Test',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '200 questions • 120 minutes',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 10,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     'Start Test',
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProgressCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _ProgressStat(
//                   label: 'Best Score',
//                   value: '850',
//                   color: Colors.green,
//                 ),
//                 _ProgressStat(
//                   label: 'Average',
//                   value: '750',
//                   color: Colors.blue,
//                 ),
//                 _ProgressStat(
//                   label: 'Tests',
//                   value: '15',
//                   color: Colors.orange,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             const Divider(),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Target Score',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       const Text(
//                         '900',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     // Navigate to detailed progress
//                   },
//                   child: const Text('View Details'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SectionButton extends StatelessWidget {
//   final String title;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final Color color;

//   const _SectionButton({
//     required this.title,
//     required this.isSelected,
//     required this.onTap,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? color : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(
//           title,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: isSelected ? Colors.white : Colors.grey[700],
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ToeicPartCard extends StatelessWidget {
//   final int partNumber;
//   final String title;
//   final String description;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   const _ToeicPartCard({
//     required this.partNumber,
//     required this.title,
//     required this.description,
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
//             ),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, color: color, size: 24),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Part $partNumber',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 description,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ProgressStat extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;

//   const _ProgressStat({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }

  

  
// }