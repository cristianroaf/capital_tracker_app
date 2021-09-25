import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Cristian\s capital tracker'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FocusNode _focus_degiro = FocusNode();
  TextEditingController _textFieldController_degiro = TextEditingController();
  FocusNode _focus_etoro = FocusNode();
  TextEditingController _textFieldController_etoro = TextEditingController();
  FocusNode _focus_rforex = FocusNode();
  TextEditingController _textFieldController_rforex = TextEditingController();
  FocusNode _focus_kraken = FocusNode();
  TextEditingController _textFieldController_kraken = TextEditingController();
  FocusNode _focus_caixa = FocusNode();
  TextEditingController _textFieldController_caixa = TextEditingController();

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  double monthly_salary = 1714.92;
  double degiro_value = 0;
  double etoro_value = 0;
  double rforex_value = 0;
  double kraken_value = 0;
  double caixa_value = 0;

  double total_money = 0;

  Future<void> loadDataFromSharedPreferences() async {
    prefs.then((SharedPreferences prefs) {
      degiro_value = (prefs.getDouble('degiro_value') ?? 0);
      _textFieldController_degiro.text = degiro_value.toString() + "€";
      etoro_value = (prefs.getDouble('etoro_value') ?? 0);
      _textFieldController_etoro.text = etoro_value.toString() + "€";
      rforex_value = (prefs.getDouble('rforex_value') ?? 0);
      _textFieldController_rforex.text = rforex_value.toString() + "€";
      kraken_value = (prefs.getDouble('kraken_value') ?? 0);
      _textFieldController_rforex.text = kraken_value.toString() + "€";
      caixa_value = (prefs.getDouble('caixa_value') ?? 0);
      _textFieldController_caixa.text = caixa_value.toString() + "€";
      total_money = degiro_value + etoro_value + rforex_value + kraken_value + caixa_value;
    });
  }

  void updateTextFields(){
    _textFieldController_degiro.text = degiro_value.toString() + "€";
    _textFieldController_etoro.text = etoro_value.toString() + "€";
    _textFieldController_rforex.text = rforex_value.toString() + "€";
    _textFieldController_kraken.text = kraken_value.toString() + "€";
    _textFieldController_caixa.text = caixa_value.toString() + "€";
  }
  
  int getMonthDays(int month){
    if(month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12){
      return 31;
    }else if(month == 4 || month == 6 || month == 9 || month == 11){
      return 30;
    }
    return 28;
  }

  Future<double> getEURUSDrate() async {
    http.Client client = new http.Client();
    final res = await client.get(Uri.parse('http://api.exchangeratesapi.io/v1/latest?access_key=99d759f144730f258d70e308e59282ae'));
    Map<String,dynamic> response = jsonDecode(res.body);

    return response['rates']['USD'];
    
  }

  double getMonthlyMoney(){
    DateTime date = DateTime.now();
    int total_day_secs = 86400;
    int month_days = getMonthDays(date.month);
    int total_month_seconds = total_day_secs * month_days;
    double current_seconds = date.hour*3600 + date.minute*60 + date.second + date.millisecond/1000 + date.microsecond/1000000;
    double remaining_day_seconds = total_day_secs-current_seconds;
    double remaining_month_seconds = (month_days-date.day-1)*total_day_secs + remaining_day_seconds;
    double percentage = remaining_month_seconds/total_month_seconds;
    return (1-percentage)*monthly_salary;
  }

  @override
  void initState() {
    _focus_degiro = FocusNode();
    _focus_degiro.addListener(() {
      if (_focus_degiro.hasFocus) _textFieldController_degiro.clear();
    });
    _focus_etoro.addListener(() {
      if (_focus_degiro.hasFocus) _textFieldController_degiro.clear();
    });
    _focus_rforex.addListener(() {
      if (_focus_degiro.hasFocus) _textFieldController_degiro.clear();
    });
    _focus_kraken.addListener(() {
      if (_focus_kraken.hasFocus) _textFieldController_kraken.clear();
    });
    _focus_caixa.addListener(() {
      if (_focus_degiro.hasFocus) _textFieldController_degiro.clear();
    });

    loadDataFromSharedPreferences();
    Timer.periodic(Duration(milliseconds: 100), (Timer t) => setState(() { total_money = degiro_value + etoro_value + rforex_value + kraken_value + caixa_value + getMonthlyMoney();}));
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text("Capital tracker"),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Material(
                  type: MaterialType.canvas,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children : [
                        Image(image: AssetImage("assets/degiro.png"),
                        height: 50,
                        width: 50,),
                        SizedBox(width: 10,),
                        Text('Degiro:',
                          style: TextStyle(color: Colors.black, fontSize: 25.0),
                        ),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              controller: _textFieldController_degiro,
                              focusNode: _focus_degiro,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                border: OutlineInputBorder()
                              ),
                              onFieldSubmitted: (String value) async {
                                degiro_value = double.parse(value);
                                prefs.then((SharedPreferences prefs) {
                                  prefs.setDouble("degiro_value", double.parse(value));
                                });
                                updateTextFields();
                              },
                            ),
                          ),
                        ),
                      ]
                    ),
                  )
                ),
                Material(
                  type: MaterialType.canvas,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children : [
                        Image(image: AssetImage("assets/etoro.png"),
                        height: 50,
                        width: 50,),
                        SizedBox(width: 10,),
                        Text('eToro:',
                        style: TextStyle(color: Colors.black, fontSize: 25.0),
                        ),
                        SizedBox(width: 8,),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              controller: _textFieldController_etoro,
                              focusNode: _focus_etoro,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                border: OutlineInputBorder()
                              ),
                              onFieldSubmitted: (String value) async {
                                etoro_value = double.parse(value);
                                prefs.then((SharedPreferences prefs) {
                                  prefs.setDouble("etoro_value", double.parse(value));
                                });
                                updateTextFields();
                              },
                            ),
                          ),
                        ),
                      ]
                    ),
                  )
                ),
                Material(
                  type: MaterialType.canvas,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children : [
                        Image(image: AssetImage("assets/roboforex.png"),
                        height: 50,
                        width: 50,),
                        SizedBox(width: 9,),
                        Text('Rforex:',
                        style: TextStyle(color: Colors.black, fontSize: 25.0),
                        ),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              controller: _textFieldController_rforex,
                              focusNode: _focus_rforex,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                border: OutlineInputBorder()
                              ),
                              onFieldSubmitted: (String value) async {
                                rforex_value = double.parse(value);
                                double eurusdrate = await getEURUSDrate();
                                rforex_value = rforex_value/eurusdrate;
                                value = rforex_value.toStringAsFixed(2);
                                rforex_value = double.parse(value);
                                prefs.then((SharedPreferences prefs) {
                                  prefs.setDouble("rforex_value", double.parse(value));
                                });
                                updateTextFields();
                              },
                            ),
                          ),
                        ),
                      ]
                    ),
                  )
                ),
                Material(
                  type: MaterialType.canvas,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children : [
                        Image(image: AssetImage("assets/kraken.png"),
                        height: 50,
                        width: 50,),
                        SizedBox(width:5,),
                        Text('Kraken:',
                        style: TextStyle(color: Colors.black, fontSize: 25.0),
                        ),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              controller: _textFieldController_kraken,
                              focusNode: _focus_kraken,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                border: OutlineInputBorder()
                              ),
                              onFieldSubmitted: (String value) async {
                                kraken_value = double.parse(value);
                                prefs.then((SharedPreferences prefs) {
                                  prefs.setDouble("kraken_value", double.parse(value));
                                });
                                updateTextFields();
                              },
                            ),
                          ),
                        ),
                      ]
                    ),
                  )
                ),
                Material(
                  type: MaterialType.canvas,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children : [
                        Image(image: AssetImage("assets/lacaixa.png"),
                        height: 50,
                        width: 50,),
                        SizedBox(width: 10,),
                        Text('Caixa:',
                        style: TextStyle(color: Colors.black, fontSize: 25.0),
                        ),
                        SizedBox(width: 8,),
                          Flexible(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              controller: _textFieldController_caixa,
                              focusNode: _focus_caixa,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                border: OutlineInputBorder()
                              ),
                              onFieldSubmitted: (String value) async {
                                caixa_value = double.parse(value);
                                prefs.then((SharedPreferences prefs) {
                                  prefs.setDouble("caixa_value", double.parse(value));
                                });
                                updateTextFields();
                              },
                            ),
                          ),
                        ),
                      ]
                    ),
                  )
                ),
                Material(
                  type: MaterialType.canvas,
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 500),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.70,
                          height: MediaQuery.of(context).size.width * 0.20,
                          decoration: BoxDecoration(
                          
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.amber,
                          border: Border.all(width: 3)
                          
                          ),
                          child: Center(
                            child: Text(double.parse((total_money).toStringAsFixed(5)).toString().length == 11 ? double.parse((total_money).toStringAsFixed(5)).toString() + "€" : double.parse((total_money).toStringAsFixed(5)).toString() + "0€",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily: "monospace"),
                            ),
                          ),
                        ),
                      ),
                    )
                  )
                ),
              ]
            )
          ),
        ],
      )
    );
  }
}