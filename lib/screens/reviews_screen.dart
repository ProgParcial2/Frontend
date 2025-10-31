import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../providers/auth_provider.dart';
import '../services/review_service.dart';

class ReviewsScreen extends StatefulWidget {
  final int productId;
  final String productName;

  const ReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late ReviewService _service;
  bool loading = true;
  List<Review> reviews = [];
  int rating = 0;
  final commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      _service = ReviewService(auth);
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    setState(() => loading = true);
    try {
      final list = await _service.getByProduct(widget.productId);
      setState(() => reviews = list);
    } catch (e) {
      debugPrint('Error al cargar reseñas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar reseñas: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _createReview() async {
    if (rating == 0 || commentCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes ingresar calificación y comentario.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await _service.create(widget.productId, rating, commentCtrl.text);
      commentCtrl.clear();
      rating = 0;
      await _loadReviews();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reseña publicada ✅')),
      );
    } catch (e) {
      debugPrint('Error al crear reseña: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al publicar reseña: $e')),
      );
    }
  }

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reseñas de ${widget.productName}')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔹 Lista de reseñas existentes
                Expanded(
                  child: reviews.isEmpty
                      ? const Center(
                          child: Text('Aún no hay reseñas para este producto.'),
                        )
                      : ListView.builder(
                          itemCount: reviews.length,
                          itemBuilder: (_, i) {
                            final r = reviews[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo,
                                child: Text(
                                  r.rating.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(r.comment),
                              subtitle: Text(
                                '⭐ ${r.rating} | ${r.date.day}/${r.date.month}/${r.date.year}',
                              ),
                            );
                          },
                        ),
                ),

                const Divider(height: 1),

                // 🔹 Formulario para crear reseña
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tu calificación:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(5, (i) {
                          final starIndex = i + 1;
                          return IconButton(
                            icon: Icon(
                              starIndex <= rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () =>
                                setState(() => rating = starIndex),
                          );
                        }),
                      ),
                      TextField(
                        controller: commentCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Escribe tu reseña...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _createReview,
                        icon: const Icon(Icons.send),
                        label: const Text('Publicar reseña'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
