import "package:flutter/material.dart";

import '../providers/product.dart';
import "../providers/products.dart";

import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit";
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // final _priceFocusNode = FocusNode();
  final _imageurlController = TextEditingController();
  final _imageurlFocus = FocusNode();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _editable =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');
  var _isLoading = false;

  @override
  void initState() {
    _imageurlFocus.addListener(_lostFocus);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String;
      if (productId.isNotEmpty) {
        _editable = Provider.of<Products>(context).findById(productId);
        _imageurlController.text = _editable.imageUrl;
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageurlFocus.removeListener(_lostFocus);
    _imageurlController.dispose();
    super.dispose();
  }

  void _lostFocus() {
    if (!_imageurlFocus.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    //validate returns true if all validations are null and false if even one has text;
    final isValid = _form.currentState?.validate();
    if (isValid as bool) {
      _form.currentState?.save();
      setState(() {
        _isLoading = true;
      });
      if (_editable.id.isNotEmpty) {
        await Provider.of<Products>(context, listen: false)
            .editProducts(_editable.id, _editable);
      } else {
        try {
          await Provider.of<Products>(context, listen: false)
              .addProducts(_editable);
        } catch (error) {
          await showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text('An error occured'),
                  content: const Text('Something went wrong'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Okay!'),
                    )
                  ],
                );
              });
        }
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  //TRY CATCH METHOD of SAVE FORM
  // Provider.of<Products>(context, listen: false)
  //           .addProducts(_editable)
  //           .catchError((err) {
  //         return showDialog<Null>(
  //             context: context,
  //             builder: (ctx) {
  //               return AlertDialog(
  //                 title: const Text('An error occured'),
  //                 content: const Text('Something went wrong'),
  //                 actions: [
  //                   TextButton(
  //                     onPressed: () {
  //                       Navigator.of(ctx).pop();
  //                     },
  //                     child: const Text('Okay!'),
  //                   )
  //                 ],
  //               );
  //             });
  //       }).then((value) {
  //         setState(() {
  //           _isLoading = false;
  //         });
  //         Navigator.of(context).pop();
  //       });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Products'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.amber,
            ))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _editable.title,
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(fontSize: 18),
                        validator: (val) {
                          if (val?.isEmpty as bool) {
                            return 'Enter a value';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          _editable = Product(
                              isFavorite: _editable.isFavorite,
                              id: _editable.id,
                              title: val as String,
                              description: _editable.description,
                              price: _editable.price,
                              imageUrl: _editable.imageUrl);
                        },
                        // onFieldSubmitted: (_) {
                        //   FocusScope.of(context).requestFocus(_priceFocusNode);
                        // },
                      ),
                      TextFormField(
                        initialValue: _editable.price == 0.0
                            ? ""
                            : _editable.price.toString(),
                        decoration: const InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 18),
                        onSaved: (val) {
                          _editable = Product(
                              isFavorite: _editable.isFavorite,
                              id: _editable.id,
                              title: _editable.title,
                              description: _editable.description,
                              price: double.parse(val as String),
                              imageUrl: _editable.imageUrl);
                        },
                        validator: (val) {
                          if (val?.isEmpty as bool) {
                            return 'Enter a value';
                          }
                          if (double.tryParse(val as String) == null) {
                            return "Enter a number";
                          }
                          if (double.parse(val as String) <= 0) {
                            return 'Enter a number greater than 0';
                          }
                          return null;
                        },
                        // focusNode: _priceFocusNode,
                      ),
                      TextFormField(
                        initialValue: _editable.description,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(fontSize: 18),
                        maxLines: 3,
                        onSaved: (val) {
                          _editable = Product(
                              isFavorite: _editable.isFavorite,
                              id: _editable.id,
                              title: _editable.title,
                              description: val as String,
                              price: _editable.price,
                              imageUrl: _editable.imageUrl);
                        },
                        validator: (val) {
                          if (val?.isEmpty as bool) {
                            return 'Enter a description';
                          }
                          if ((val?.length as num) < 10) {
                            return 'Description should be atleast 10 characters long';
                          }
                          return null;
                        },
                        // focusNode: _priceFocusNode,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(top: 12, right: 12),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageurlController.text.isEmpty
                                ? const Text('Enter a URL')
                                : Image.network(
                                    _imageurlController.text,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              style: const TextStyle(fontSize: 18),
                              controller: _imageurlController,
                              focusNode: _imageurlFocus,
                              onEditingComplete: () {
                                setState(() {});
                              },
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              onSaved: (val) {
                                _editable = Product(
                                    isFavorite: _editable.isFavorite,
                                    id: _editable.id,
                                    title: _editable.title,
                                    description: _editable.description,
                                    price: _editable.price,
                                    imageUrl: val as String);
                              },
                              validator: (val) {
                                //can add these validations to update image as well on focus change
                                if (val?.isEmpty as bool) {
                                  return "Enter a value";
                                }
                                if (!(val?.startsWith('http') as bool)) {
                                  return 'Please enter a valid URL';
                                }
                                if (!(val?.endsWith('.png') as bool) &&
                                    !(val?.endsWith('.jpg') as bool) &&
                                    !(val?.endsWith('.jpeg') as bool)) {
                                  return 'Please Enter an Image URL';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
