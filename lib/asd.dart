import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furpa_terminal/mixins/validation_mixin.dart';
import 'package:furpa_terminal/models/orderModels/cart.dart';
import 'package:furpa_terminal/models/orderModels/cartLine.dart';
import 'package:furpa_terminal/models/warehouseReceiving/warehouseReceivingDocument.dart';
import 'package:furpa_terminal/models/warehouseReceiving/warehouseReceivingLine.dart';
import 'package:furpa_terminal/services/productMovementsService.dart';
import 'package:furpa_terminal/widgets/alertDialogWidget.dart';
import 'package:furpa_terminal/widgets/receivedQuantityDialogWidget.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class WarehouseReceivingPage extends StatefulWidget {
  @override
  _WarehouseReceivingPageState createState() => _WarehouseReceivingPageState();
}



class _WarehouseReceivingPageState extends State<WarehouseReceivingPage>
    with TickerProviderStateMixin, ValidationMixin {
  FocusNode _focusNode;
  TabController _tabController;
TextEditingController _txtDocumentNo ;
TextEditingController _barcodeController;
TextEditingController _txtPerson;
bool _shouldEnable = true;
bool _saveButtonPressed = false;
Cart _productsToReceive;
List<CartLine> _filteredCartLines;

List<WarehouseReceivingLine> _receivedProducts;
List<String> _productCodeList;
int _lengthInDocument = 0;
final _formKey = GlobalKey<FormState>();
 
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
    length: 2, vsync: _WarehouseReceivingPageState(), initialIndex: 0);
    _txtDocumentNo = TextEditingController();
    _barcodeController = TextEditingController();
    _txtPerson = TextEditingController();
    _productsToReceive = Cart(List<CartLine>());
    _filteredCartLines = List<CartLine>();
    _receivedProducts = List<WarehouseReceivingLine>();
    _productCodeList = List<String>();
    _tabController.index = 0;
    _focusNode = FocusNode();
  }
  bool isDialogOpen = false;
  @override
  void dispose() {
    _tabController.dispose();
    _focusNode.dispose();
    _txtDocumentNo.dispose();
    _barcodeController.dispose();
    _txtPerson.dispose();
    _productsToReceive.cartLines.clear();
    _filteredCartLines.clear();
    _receivedProducts.clear();
    _productCodeList.clear();
    _lengthInDocument = 0;
    super.dispose();
  }

  CartLine _cartLine;

  String _barcode = "";
  String barcodeScanRes = "";
  Future<String> scanBarcodeNormal() async {
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Vazgeç", true, ScanMode.BARCODE);
      _barcode = barcodeScanRes;
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    return barcodeScanRes;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Depo Mal Kabul"),
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: <Widget>[
          Tab(
            icon: Icon(
              Icons.search,
              color: Colors.black,
            ),
          ),
          Tab(
              icon: Icon(
            Icons.add_shopping_cart,
            color: Colors.black,
          ))
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _buildDocumentDetailTab(),
          _buildReceivedProductsTab()
        ],
      ),
    );
  }

  Container _buildDocumentDetailTab() {
    return Container(
      child: ListView(
        children: <Widget>[
          Card(
              margin: EdgeInsets.only(top: 20),
              child: ListTile(
                title: Row(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: TextFormField(
                            controller: _txtPerson,
                            autovalidate: true,
                            validator: (value) => validatePersonalName(value),
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            maxLength: 25,
                            maxLengthEnforced: true,
                            decoration: InputDecoration(
                              labelText: "Teslim Alan",
                              hintText: "Depo Mal Kabul'ü Yapan Kişi.",
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(top: 15),
                                child: Icon(Icons.person),
                              ),
                            ),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20))),
                  ],
                ),
              )),
          Card(
              child: ListTile(
            title: Row(
              children: <Widget>[
                Expanded(
                    flex: 4,
                    child: TextFormField(
                        enabled: _shouldEnable,
                        controller: _txtDocumentNo,
                        inputFormatters: <TextInputFormatter>[
                          MaskTextInputFormatter(
                            mask: "################",
                              filter: {"#": RegExp(r'[A-Za-z0-9]')})
                              // mask: "FRM#############",
                              // filter: {"#": RegExp(r'[0-9]')})
                        ],
                        //keyboardType: TextInputType.number,
                        autovalidate: true,
                        validator: (value) {
                          if (value == "" || value == null)
                            return "Bu alan zorunludur.";
                          return null;
                        },
                        maxLength: 16,
                        maxLengthEnforced: true,
                        decoration: InputDecoration(
                          labelText: "Evrak No",
                          hintText: "Evrak No giriniz.",
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: Icon(FontAwesomeIcons.barcode),
                          ),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ))),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    splashColor: Colors.red,
                    icon: Icon(Icons.photo_camera, size: 40),
                    onPressed: () async {
                      var barcodeScan = await scanBarcodeNormal();
                      if (barcodeScan != "-1") {
                        setState(() {
                          _barcode = barcodeScan;
                        });
                        _txtDocumentNo.text = _barcode;
                      }
                    },
                  ),
                )
              ],
            ),
          )),
          Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.symmetric(horizontal: 5),
            height: 50,
            child: FlatButton(
              color: Colors.blue[100],
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.red)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.attach_file),
                  Text(
                    "Evrağı Çağır",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
              onPressed: () async {
                if (_txtDocumentNo.text == "" || _txtDocumentNo.text == null) {
                  await showDialog(
                      context: context,
                      builder: (context) => AlertDialogWidget(
                          "Hata", "Lütfen Evrak No Giriniz!"));
                  return;
                }
                if (_txtPerson.text == "" || _txtPerson.text == null) {
                  await showDialog(
                      context: context,
                      builder: (context) => AlertDialogWidget(
                          "Hata", "Lütfen Ad Soyad Giriniz!"));
                  return;
                }
                getShippedProducts();
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.symmetric(horizontal: 5),
            height: 50,
            child: FlatButton(
              color: Colors.green[100],
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.red)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.autorenew),
                  Text(
                    "Yeni Evrak",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
              onPressed: () {
                _resetToPageDefaults();
              },
            ),
          )
        ],
      ),
    );
  }

  Container _buildReceivedProductsTab() {
    return Container(
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: TextFormField(
                      autofocus: true,
                      controller: _barcodeController,
                      maxLines: null,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      focusNode: _focusNode,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      onTap: () => _barcodeController.clear(),
                      autovalidate: true,
                      validator: (value) {
                        if (value.contains('\n')) {
                          _barcodeController.text = value.replaceAll('\n', '');
                          _cartLine = _filteredCartLines.firstWhere(
                              (cartLine) =>
                                  cartLine.product.barcode ==
                                  _barcodeController.text, orElse: () {
                            return null;
                          });
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) async {
                        _barcodeController.text = value;
                        _cartLine = _filteredCartLines.firstWhere(
                            (cartLine) =>
                                cartLine.product.barcode ==
                                _barcodeController.text, orElse: () {
                          return null;
                        });
                        if (_cartLine != null)
                          await showReceivedQuantityDialog(_cartLine);
                        else {
                          await showDialog(
                              context: context,
                              builder: (context) => AlertDialogWidget("Uyarı",
                                  "Evrakta ${_barcodeController.text} barkoda sahip ürün bulunamadı."));
                          return;
                        }
                      },
                      decoration: InputDecoration(
                          hintText: "Barkod Okutunuz.",
                          labelText: "Barkod",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.red,
                      textColor: Colors.white,
                      onPressed: () async {

                        if(_receivedProducts.any((element) => element.cartline.product.barcode))
                        _cartLine = _filteredCartLines.firstWhere(
                            (filterLine) =>
                                filterLine.product.barcode.trim() ==
                                _barcodeController.text.trim(), orElse: () {
                          return null;
                        });
                        if (_cartLine != null)
                          await showReceivedQuantityDialog(_cartLine);
                        else {
                          await showDialog(
                              context: context,
                              builder: (context) => AlertDialogWidget("Uyarı",
                                  "Evrakta ${_barcodeController.text} barkoda sahip ürün bulunamadı."));
                          return;
                        }
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.add_shopping_cart,
                          ),
                          Text(
                            " Ekle ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    splashColor: Colors.red,
                    icon: Icon(Icons.photo_camera, size: 40),
                    onPressed: () async {
                      var barcodeScan = await scanBarcodeNormal();
                      if (barcodeScan != "-1") {
                        setState(() {
                          _barcode = barcodeScan;
                        });
                        _barcodeController.text = _barcode;
                        _cartLine = _filteredCartLines.firstWhere(
                            (filterLine) =>
                                filterLine.product.barcode ==
                                _barcodeController.text, orElse: () {
                          return null;
                        });
                        if (_cartLine != null) {
                          await showReceivedQuantityDialog(_cartLine);
                        } else {
                          await showDialog(
                              context: context,
                              builder: (context) => AlertDialogWidget("Uyarı",
                                  "Evrakta ${_barcodeController.text} barkoda sahip ürün bulunamadı."));
                          return;
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            child: Text(
              " Kabul Edilen: " +
                  _receivedProducts.length.toString() +
                  " Evraktaki: " +
                  _lengthInDocument.toString(),
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: _receivedProducts.length,
            itemBuilder: (context, index) =>
                receivedProductTile(_receivedProducts[index]),
          )),
          Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                height: 50,
                child: FlatButton(
                  color: Colors.red[100],
                  shape: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[Icon(Icons.save), Text("Kaydet")],
                  ),
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('Kayıt İşlemi'),
                              content:
                                  Text('İşleme devam etmek istiyor musunuz?'),
                              actions: [
                                FlatButton(
                                  textColor: Color(0xFF6200EE),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Hayır'),
                                ),
                                FlatButton(
                                  textColor: Color(0xFF6200EE),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _register();
                                  },
                                  child: Text('Evet'),
                                ),
                              ],
                            ));
                    /*if (_txtPerson.text == "" || _txtPerson.text == null) {
                      await showDialog(
                              context: context,
                              builder: (context) => AlertDialogWidget(
                                  "Uyarı!", "Lütfen Ad Soyad Giriniz!"))
                          .then((onValue) {
                        setState(() {});
                        _tabController.index = 0;
                      });
                      return;
                    }
                    if (_txtPerson.text.length < 6) {
                      await showDialog(
                              context: context,
                              builder: (context) => AlertDialogWidget("Uyarı!",
                                  "Ad Soyad\nEn Az 6 Karakter Olmalıdır."))
                          .then((onValue) {
                        setState(() {});
                        _tabController.index = 0;
                      });
                      return;
                    }
                    if (_receivedProducts.length != _lengthInDocument) {
                      await showDialog(
                          context: context,
                          builder: (context) => AlertDialogWidget("Uyarı!",
                              "Lütfen Evraktaki Tüm Ürünlerin Mal Kabulünü gerçekleştiriniz."));
                      return;
                    }
                    if (_receivedProducts.length == 0) return;
                    if (_saveButtonPressed) return;

                    _saveButtonPressed = true;
                    try {
                      await ProductMovementsService().acceptWarehouseReceiving(
                          WarehouseReceivingDocument(_txtDocumentNo.text,
                              _txtPerson.text, _receivedProducts));
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialogWidget(
                              "Bilgi", "Mal Kabul onaylandı."));
                      _resetToPageDefaults();
                    } catch (e) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialogWidget("Uyarı!",
                              "Bir hata oluştu. Lütfen Daha sonra Tekrar deneyiniz."));
                    }
                    _saveButtonPressed = false;*/
                  },
                ),
              )),
            ],
          )
        ],
      ),
    );
  }

  void _resetToPageDefaults() {
    setState(() {
      _productsToReceive.cartLines.clear();
      _filteredCartLines.clear();
      _receivedProducts.clear();
      _txtDocumentNo.clear();
      _txtPerson.clear();
      _barcodeController.clear();
      _shouldEnable = true;
      _productCodeList.clear();
      _lengthInDocument = 0;
    });
  }

  //Kayıt İşlemi
  _register() async {
    if (_txtPerson.text == "" || _txtPerson.text == null) {
      await showDialog(
              context: context,
              builder: (context) =>
                  AlertDialogWidget("Uyarı!", "Lütfen Ad Soyad Giriniz!"))
          .then((onValue) {
        setState(() {});
        _tabController.index = 0;
      });
      return;
    }
    if (_txtPerson.text.length < 6) {
      await showDialog(
              context: context,
              builder: (context) => AlertDialogWidget(
                  "Uyarı!", "Ad Soyad\nEn Az 6 Karakter Olmalıdır."))
          .then((onValue) {
        setState(() {});
        _tabController.index = 0;
      });
      return;
    }
    if (_receivedProducts.length != _lengthInDocument) {
      await showDialog(
          context: context,
          builder: (context) => AlertDialogWidget("Uyarı!",
              "Lütfen Evraktaki Tüm Ürünlerin Mal Kabulünü gerçekleştiriniz."));
      return;
    }
    if (_receivedProducts.length == 0) return;
    if (_saveButtonPressed) return;

    _saveButtonPressed = true;
    //try {
      showProgressDialog();
      await ProductMovementsService()
          .acceptWarehouseReceiving(WarehouseReceivingDocument(
              _txtDocumentNo.text, _txtPerson.text, _receivedProducts))
          .then((onValue) {
        if (onValue != "Error") {
           if (isDialogOpen) {
          isDialogOpen = false;
          Navigator.pop(context);
        }
          showDialog(
              context: context,
              builder: (context) =>
                  AlertDialogWidget("Bilgi", "Mal Kabul onaylandı."));
          _resetToPageDefaults();
        }else{
           if (isDialogOpen) {
          isDialogOpen = false;
          Navigator.pop(context);
        }
          showDialog(
              context: context,
              builder: (context) =>
                  AlertDialogWidget("Bilgi", "Mal Kabul işlemi onaylanmadı. Evraktaki satır sayısı ile terminal ekranındaki satır sayısının aynı olduğundan emin olunuz."));
        }
      }).catchError((onError){
        if (isDialogOpen) {
          isDialogOpen = false;
          Navigator.pop(context);
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialogWidget("Uyarı!",
              "Bir hata oluştu. Bağlantınızı kontrol ettikten sonra tekrar deneyiniz."));
      });/*.timeout(Duration(minutes: 5),onTimeout: (){
         if (isDialogOpen) {
          isDialogOpen = false;
          Navigator.pop(context);
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialogWidget("Uyarı!",
              "Bir bağlantı problemi oluştu. Bağlantınızı kontrol ettikten sonra tekrar deneyiniz."));
      });*/
   /* } catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => AlertDialogWidget("Uyarı!",
              "Bir hata oluştu. Bağlantınızı kontrol ettikten sonra tekrar deneyiniz."));
    }*/
    _saveButtonPressed = false;
  }

  void getShippedProducts() async {
    showProgressDialog();
    _productsToReceive = await ProductMovementsService()
        .getWarehouseShippingDetailsByDocumentNo(_txtDocumentNo.text).catchError((onError){
          Navigator.pop(context);
           showDialog(
          context: context,
          builder: (context) => AlertDialogWidget(
              "Hata", "Beklenmedik bir hata oluştu. İnternet bağlantınızı kontrol ettikten sonra tekrar deneyiniz."));
      return;
        });
        Navigator.pop(context);
    if (_productsToReceive.cartLines.length == 0) {
      await showDialog(
          context: context,
          builder: (context) => AlertDialogWidget(
              "Uyarı", "Depo Mal Kabul Yapılacak Evrak Bulunamadı."));
      return;
    }
    _filteredCartLines = _productsToReceive.cartLines;

     _filteredCartLines.forEach((f)=>{
      print(f.product.productCode + " => " +f.product.barcode)
    });
    //print("Sayi ${_filteredCartLines.length}");
    _receivedProducts = List<WarehouseReceivingLine>();
    _shouldEnable = false;

    _filteredCartLines.forEach((p) {
      _productCodeList.add(p.product.productCode+" "+p.quantity.toString());
    });
    

    setState(() {});
    _lengthInDocument = _productCodeList.toSet().toList().length;
    _tabController.index = 1;
    _focusNode.requestFocus();
  }

  double _receivedQuantity;
  Future showReceivedQuantityDialog(CartLine _cartLine) async {
    _receivedQuantity = await showDialog(
        context: context,
        builder: (context) => ReceivedQuantityDialog(_cartLine.product));
    if (_receivedQuantity != null) {
      if (_receivedProducts.any((p) =>
          p.cartLine.product.productCode == _cartLine.product.productCode)) {
        _receivedProducts
            .firstWhere((p) =>
                p.cartLine.product.productCode == _cartLine.product.productCode)
            .receivedQuantity += _receivedQuantity;
      } else {
        var lastConsumingDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(DateTime.now().year),
          lastDate: DateTime(DateTime.now().year + 10),
          initialDatePickerMode: DatePickerMode.year,
        ).then((onValue) {
          return onValue;
        });
        if (lastConsumingDate != null)
          _receivedProducts.add(WarehouseReceivingLine(
              _cartLine, _receivedQuantity, lastConsumingDate));
        else {
          await showDialog(
              context: context,
              builder: (context) =>
                  AlertDialogWidget("Uyarı!", "S.K.T Zorunludur."));
          return;
        }
      }
      setState(() {});
      _barcodeController.clear();
      _focusNode.requestFocus();
    }
    _barcodeController.clear();
    _focusNode.requestFocus();
  }

  showProgressDialog() {
    isDialogOpen = true;
    return showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context) => Center(child: CircularProgressIndicator()));
  }

  showErrorDialog() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialogWidget("Uyarı!",
              "Bir hata oluştu. Bağlantınızı kontrol ettikten sonra tekrar deneyiniz."));
  }

  ListTile shippedProductTile(CartLine _cartLine) {
    return ListTile(
      title: Text("${_cartLine.product.productName}"),
      subtitle: Text(
          "${_cartLine.product.productCode} / ${_cartLine.quantity} ${_cartLine.product.unitName}"),
      onTap: () {
        showReceivedQuantityDialog(_cartLine);
      },
    );
  }

  Container receivedProductTile(
      WarehouseReceivingLine _warehouseReceivingLine) {
    return Container(
        color: paintQuantityDifference(
            _warehouseReceivingLine.cartLine.quantity,
            _warehouseReceivingLine.receivedQuantity),
        child: Dismissible(
          key: Key(_warehouseReceivingLine.cartLine.product.productCode),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            setState(() {
              _receivedProducts
                  .removeAt(_receivedProducts.indexOf(_warehouseReceivingLine));
            });
          },
          background: Container(
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(
                  Icons.delete_sweep,
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  "  Sil  ",
                  style: TextStyle(fontSize: 23, color: Colors.white),
                )
              ],
            ),
          ),
          child: ListTile(
            title:
                Text("${_warehouseReceivingLine.cartLine.product.productName}"),
            subtitle: Text(
                "${_warehouseReceivingLine.cartLine.product.productCode} / ${_warehouseReceivingLine.cartLine.quantity} ${_warehouseReceivingLine.cartLine.product.unitName} / SKT: ${_warehouseReceivingLine.lastConsumingDate.day}.${_warehouseReceivingLine.lastConsumingDate.month}.${_warehouseReceivingLine.lastConsumingDate.year}"),
            trailing: Text(
                "${_warehouseReceivingLine.receivedQuantity} ${_warehouseReceivingLine.cartLine.product.unitName}"),
          ),
        ));
  }

  Color paintQuantityDifference(double quantity, double receivedQuantity) {
    if (quantity < receivedQuantity) return Colors.orange[400];
    if (receivedQuantity < quantity) return Colors.teal[300];

    return Colors.white;
  }
}
