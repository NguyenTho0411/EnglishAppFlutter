import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_manager.dart';

class BookReadingPage extends StatefulWidget {
  const BookReadingPage({Key? key}) : super(key: key);

  @override
  State<BookReadingPage> createState() => _BookReadingPageState();
}

class _BookReadingPageState extends State<BookReadingPage> {
  final List<Book> _mockBooks = [
    Book(
      id: '1',
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      description: 'A classic American novel about the Jazz Age and the American Dream.',
      coverImage: 'https://picsum.photos/200/300?random=1',
      category: 'Classic Literature',
      pages: 180,
      difficulty: 'Intermediate',
      content: [
        'Chapter 1\n\nIn my younger and more vulnerable years my father gave me some advice that I\'ve been turning over in my mind ever since.\n\n"Whenever you feel like criticizing anyone," he told me, "just remember that all the people in this world haven\'t had the advantages that you\'ve had."',
        'Chapter 2\n\nAbout half way between West Egg and New York the motor road hastily joins the railroad and runs parallel to it for a quarter of a mile, so as to shrink away from a certain desolate area of land. This is a valley of ashes—a fantastic farm where ashes grow like wheat into ridges and hills and grotesque gardens.',
        'Chapter 3\n\nThere was music from my neighbor\'s house through the summer nights. In his blue gardens men and girls came and went like moths among the whisperings and the champagne and the stars. At high tide in the afternoon I watched his guests diving from the tower of his raft, or taking the sun on the hot sand of his beach while his two motor-boats slit the waters of the Sound.',
        'Chapter 4\n\nOn Sunday morning while church bells rang in the villages alongshore, the world and its mistress returned to Gatsby\'s house and twinkled hilariously on his lawn. "He\'s a bootlegger," said the young ladies, moving somewhere between his cocktails and his flowers. "One time he killed a man who had found out that he was nephew to Von Hindenburg and second cousin to the devil."',
        'Chapter 5\n\nWhen I came home to West Egg that night I was afraid for a moment that my house was on fire. Two o\'clock and the whole corner of the peninsula was blazing with light, which fell unreal on the shrubbery and made thin elongating glints upon the roadside wires. Turning a corner, I saw that it was Gatsby\'s house, lit from tower to cellar.',
      ],
      reviews: [],
    ),
    Book(
      id: '2',
      title: 'To Kill a Mockingbird',
      author: 'Harper Lee',
      description: 'A powerful story about racial injustice and childhood innocence in the American South.',
      coverImage: 'https://picsum.photos/200/300?random=2',
      category: 'Classic Literature',
      pages: 281,
      difficulty: 'Intermediate',
      content: [
        'Chapter 1\n\nWhen he was nearly thirteen, my brother Jem got his arm badly broken at the elbow. When it healed, and Jem\'s fears of never being able to play football were assuaged, he was seldom self-conscious about his injury. His left arm was somewhat shorter than his right; when he stood or walked, the back of his hand was at right angles to his body, his thumb parallel to his thigh.',
        'Chapter 2\n\nOur father, Atticus Finch, was a lawyer in Maycomb, Alabama. He was a man of great integrity and wisdom. "You never really understand a person until you consider things from his point of view," he often told us. "Until you climb inside of his skin and walk around in it."',
        'Chapter 3\n\nThe first day of school was always a challenge for the children of Maycomb. Dill had returned for the summer, and with him came new adventures and mischief. We spent our days exploring the neighborhood, creating imaginary worlds, and learning about the people around us.',
        'Chapter 4\n\nAs the summer progressed, Jem and I discovered more about Boo Radley, the reclusive neighbor who never left his house. The children in the neighborhood told stories about him, painting him as a monster. But Atticus warned us not to believe everything we heard.',
        'Chapter 5\n\nOne afternoon, while playing in the backyard, we noticed something unusual. Small items began appearing in the knothole of a tree near the Radley house. Gum, pennies, soap figures carved in the image of two children - Jem and me. We knew they were from Boo Radley.',
      ],
      reviews: [],
    ),
    Book(
      id: '3',
      title: '1984',
      author: 'George Orwell',
      description: 'A dystopian novel about totalitarianism and surveillance in a future society.',
      coverImage: 'https://picsum.photos/200/300?random=3',
      category: 'Science Fiction',
      pages: 328,
      difficulty: 'Advanced',
      content: [
        'Chapter 1\n\nIt was a bright cold day in April, and the clocks were striking thirteen. Winston Smith, his chin nuzzled into his breast in an effort to escape the vile wind, slipped quickly through the glass doors of Victory Mansions, though not quickly enough to prevent a swirl of gritty dust from entering along with him.',
        'Chapter 2\n\nThe hallway smelt of boiled cabbage and old rag mats. At one end of it a colored poster, too large for indoor display, had been tacked to the wall. It depicted simply an enormous face, more than a meter wide: the face of a man of about forty-five, with a heavy black mustache and ruggedly handsome features.',
        'Chapter 3\n\nWinston turned round abruptly. He had set his features into the expression of quiet optimism which it was advisable to wear when facing the telescreen. He crossed the room into the tiny kitchen. By leaving the Ministry at this time of day he had sacrificed his lunch in the canteen, and he was aware that there was no food in the kitchen except a hunk of dark-colored bread which had got to be saved for tomorrow\'s breakfast.',
        'Chapter 4\n\nThe Ministry of Truth—Minitrue, in Newspeak—which was responsible for news, entertainment, education, and the fine arts. The Ministry of Peace—Minitrue—which was responsible for war. The Ministry of Love—Miniluv—which maintained law and order. And the Ministry of Plenty—Miniplenty—which was responsible for economic affairs.',
        'Chapter 5\n\nIn the far distance a helicopter skimmed down between the roofs, hovered for an instant like a bluebottle, and darted away again with a curving flight. It was the police patrol, snooping into people\'s windows. The patrols did not matter, however. Only the Thought Police mattered.',
      ],
      reviews: [],
    ),
    Book(
      id: '4',
      title: 'Pride and Prejudice',
      author: 'Jane Austen',
      description: 'A romantic novel about manners, upbringing, morality, and marriage in early 19th-century England.',
      coverImage: 'https://picsum.photos/200/300?random=4',
      category: 'Romance',
      pages: 279,
      difficulty: 'Intermediate',
      content: [
        'Chapter 1\n\nIt is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife. However little known the feelings or views of such a man may be on his first entering a neighbourhood, this truth is so well fixed in the minds of the surrounding families, that he is considered the rightful property of some one or other of their daughters.',
        'Chapter 2\n\n"Mr. Bennet was among the earliest of those who waited on Mr. Bingley. He had always intended to visit him, though to the last always assuring his wife that he should not go; and till the evening after the visit was paid she had no knowledge of it. It was then disclosed in the following manner."',
        'Chapter 3\n\nNot all that Mrs. Bennet, however, with the assistance of her five daughters, could ask on the subject, was sufficient to draw from her husband any satisfactory description of Mr. Bingley. They attacked him in various ways—with barefaced questions, ingenious suppositions, and distant surmises; but he eluded the skill of them all.',
        'Chapter 4\n\nWhen Jane and Elizabeth were alone, the former, who had been cautious in her praise of Mr. Bingley before, expressed to her sister just how very much she admired him. "He is just what a young man ought to be," said she, "sensible, good-humoured, lively; and I never saw such happy manners!—so much ease, with such perfect good breeding!"',
        'Chapter 5\n\nWithin a short walk of Longbourn lived a family with whom the Bennets were particularly intimate. Sir William Lucas had been formerly in trade in Meryton, where he had made a tolerable fortune, and risen to the honour of knighthood by an address to the king during his mayoralty.',
      ],
      reviews: [],
    ),
    Book(
      id: '5',
      title: 'The Catcher in the Rye',
      author: 'J.D. Salinger',
      description: 'A controversial novel about teenage rebellion and alienation.',
      coverImage: 'https://picsum.photos/200/300?random=5',
      category: 'Coming of Age',
      pages: 277,
      difficulty: 'Intermediate',
      content: [
        'Chapter 1\n\nIf you really want to hear about it, the first thing you\'ll probably want to know is where I was born, and what my lousy childhood was like, and how my parents were occupied and all before they had me, and all that David Copperfield kind of crap, but I don\'t feel like going into it, if you want to know the truth.',
        'Chapter 2\n\nThe way I figure it, I\'m not going to tell you my whole life story or anything. I\'ll just tell you about this madman stuff that happened to me around last Christmas just before I got pretty run-down and had to come out here and take it easy.',
        'Chapter 3\n\nI\'m the most terrific liar you ever saw in your life. It\'s awful. If I\'m on my way to the store to buy a magazine, even, and somebody asks me where I\'m going, I\'m liable to say I\'m going to the opera. It\'s terrible.',
        'Chapter 4\n\nThe best thing, though, in that museum was that everything always stayed right where it was. Nobody\'d move. You could go there a hundred thousand times, and that Eskimo would still be just finished catching those two fish, the birds would still be on their way south, the deers would still be drinking out of that water hole.',
        'Chapter 5\n\nI\'m quite illiterate, but I read a lot. My favorite author is my brother D.B., and my next favorite is Ring Lardner. D.B.\'s a writer and all, and my brother Allie\'s dead. So I\'m reading mostly D.B.\'s stuff these days.',
      ],
      reviews: [],
    ),
    Book(
      id: '6',
      title: 'Harry Potter and the Philosopher\'s Stone',
      author: 'J.K. Rowling',
      description: 'The first book in the Harry Potter series about a young wizard\'s adventures.',
      coverImage: 'https://picsum.photos/200/300?random=6',
      category: 'Fantasy',
      pages: 223,
      difficulty: 'Beginner',
      content: [
        'Chapter 1\n\nMr. and Mrs. Dursley, of number four, Privet Drive, were proud to say that they were perfectly normal, thank you very much. They were the last people you\'d expect to be involved in anything strange or mysterious, because they just didn\'t hold with such nonsense.',
        'Chapter 2\n\nNearly ten years had passed since the Dursleys had woken up to find their nephew on the front step, but Privet Drive had hardly changed at all. The sun rose on the same tidy front gardens and lit up the brass number four on the Dursleys\' front door; it crept into their living room, which was almost exactly the same as it had been on the night when Mr. Dursley had seen that fateful news report about the owls.',
        'Chapter 3\n\nHarry Potter was a highly unusual boy in many ways. For one thing, he hated the summer holidays more than any other time of year. For another, he really wanted to do his homework but was forced to do it in secret, in the dead of night. And he also happened to be a wizard.',
        'Chapter 4\n\nIt was on the corner of the street that he noticed the first sign of something peculiar—a cat reading a map. For a second, Mr. Dursley didn\'t realize what he had seen—then he jerked his head around to look again. There was a tabby cat standing on the corner of Privet Drive, but there wasn\'t a map in sight.',
        'Chapter 5\n\nAs soon as he had finished eating, Harry put on his glasses and climbed back upstairs. Life at the Dursleys\' had always been the same, but now it was different. Now he knew he was a wizard, and that his parents hadn\'t died in a car crash, but had been killed by a powerful Dark wizard.',
      ],
      reviews: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Reading'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose a Book to Read',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Read and improve your English with our curated collection of classic books',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Books Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemCount: _mockBooks.length,
                itemBuilder: (context, index) {
                  final book = _mockBooks[index];
                  return _BookCard(
                    book: book,
                    onTap: () => _onBookSelected(book),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onBookSelected(Book book) {
    context.push('/bookReader', extra: book);
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _BookCard({
    Key? key,
    required this.book,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(book.coverImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Book Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Author
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _calculateAverageRating(book).toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${book.reviews.length})',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double _calculateAverageRating(Book book) {
    if (book.reviews.isEmpty) return 0.0;
    final totalRating = book.reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return totalRating / book.reviews.length;
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverImage;
  final String category;
  final int pages;
  final String difficulty;
  final List<String> content;
  final List<BookReview> reviews;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImage,
    required this.category,
    required this.pages,
    required this.difficulty,
    required this.content,
    required this.reviews,
  });
}

class BookReview {
  final String bookId;
  final int rating;
  final String review;
  final DateTime date;

  const BookReview({
    required this.bookId,
    required this.rating,
    required this.review,
    required this.date,
  });
}