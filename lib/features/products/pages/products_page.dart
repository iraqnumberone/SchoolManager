import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/core/database/db_helper.dart' as db;
import 'package:school_app/core/models/product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _loading = true;
  List<ProductModel> _items = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final rows = await db.DatabaseHelper.instance.queryAll(
        'products',
        orderBy: 'id DESC',
      );
      setState(() {
        _items = rows.map((e) => ProductModel.fromMap(e)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل تحميل المنتجات: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addOrEdit({ProductModel? product}) async {
    final titleCtrl = TextEditingController(text: product?.title ?? '');
    final priceCtrl = TextEditingController(
      text: product != null ? product.price.toString() : '',
    );
    final stockCtrl = TextEditingController(
      text: product != null ? product.stock.toString() : '0',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            product == null ? 'إضافة منتج' : 'تعديل منتج',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'الاسم'),
                textDirection: TextDirection.rtl,
              ),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: 'السعر'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textDirection: TextDirection.rtl,
              ),
              TextField(
                controller: stockCtrl,
                decoration: const InputDecoration(labelText: 'المخزون'),
                keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final title = titleCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text.trim());
    final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;

    // After awaiting the dialog, guard BuildContext usage
    if (!mounted) return;

    if (title.isEmpty || price == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم وسعر صحيحين')),
      );
      return;
    }

    try {
      if (product == null) {
        await db.DatabaseHelper.instance.insert('products', {
          'title': title,
          'price': price,
          'stock': stock,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        await db.DatabaseHelper.instance.update(
          'products',
          {'title': title, 'price': price, 'stock': stock},
          where: 'id = ?',
          whereArgs: [product.id],
        );
      }
      await _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
      }
    }
  }

  Future<void> _delete(ProductModel product) async {
    try {
      await db.DatabaseHelper.instance.delete(
        'products',
        where: 'id = ?',
        whereArgs: [product.id],
      );
      await _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل الحذف: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المنتجات', style: GoogleFonts.cairo()),
        backgroundColor: AppConfig.primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        backgroundColor: AppConfig.secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: _items.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppConfig.textLightColor,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'لا توجد منتجات',
                            style: GoogleFonts.cairo(
                              color: AppConfig.textSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: AppConfig.borderColor),
                      itemBuilder: (ctx, i) {
                        final p = _items[i];
                        return ListTile(
                          title: Text(
                            p.title,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'السعر: ${p.price.toStringAsFixed(2)} | المخزون: ${p.stock}',
                            style: GoogleFonts.cairo(
                              color: AppConfig.textSecondaryColor,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _addOrEdit(product: p),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _delete(p),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
