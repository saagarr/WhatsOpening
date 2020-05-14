import 'package:flutter/material.dart';
import '../ThemeData.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flu/Wrappers/EtherscanWrapper.dart';

class TransactionView extends StatefulWidget {
  @override
  _TransactionViewState createState() => _TransactionViewState();
}

class _TransactionViewState extends State<TransactionView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  bool transacting = false;
  bool noTransactions = true;
  bool loading = true;
  String hash;
  Map json = {
    "result": {"status": "0"}
  };
  bool err = false;
  @override
  void initState() {
    _transactionStatus();
    animationController =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 18),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppTheme.nearlyBlack, HexColor("#000000")],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: AppTheme.grey.withOpacity(0.6),
                    offset: Offset(1.1, 1.1),
                    blurRadius: 7.0),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Your Last Transaction',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                      letterSpacing: 0.0,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: noTransactions
                        ? Text(
                            "No Transactions yet!",
                            style: TextStyle(color: Colors.white),
                          )
                        : FlatButton(
                            onPressed: () {},
                            child: Text(
                              hash,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                letterSpacing: 0.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Row(
                              children: <Widget>[
                                noTransactions
                                    ? Text("")
                                    : !transacting
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.black,
                                          )
                                        : SpinKitWave(
                                            size: 30,
                                            color: Colors.indigo,
                                          ),
                                SizedBox(
                                  width: 20,
                                ),
                                noTransactions
                                    ? Text("")
                                    : Text(
                                        transacting
                                            ? "Not Merged yet!"
                                            : err
                                                ? "Transaction failed"
                                                : "Transaction merged",
                                        style: TextStyle(color: Colors.black),
                                      )
                              ],
                            )),
                        Expanded(
                          child: SizedBox(),
                        ),
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              loading = true;
                            });
                            _transactionStatus();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.nearlyWhite,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color:
                                        AppTheme.nearlyBlack.withOpacity(0.4),
                                    offset: Offset(8.0, 8.0),
                                    blurRadius: 8.0),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Icon(
                                Icons.refresh,
                                color: Colors.black,
                                size: 44,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _transactionStatus() async {
    await SharedPreferences.getInstance().then((prefs) async {
      var jos;
      bool transaction = prefs.getBool("transacting");
      String hash = prefs.getString("hash");
      //hash = "0x27fc3579c8fc51d1d9d673ee36efea8d0f5b2237579fd4a5d757326f5805c1fc ";
      if (transaction == true) {
        setState(() {
          transacting = true;
        });
      } else {
        setState(() {
          transacting = false;
        });
      }
      if (hash == "" || hash == null) {
        setState(() {
          noTransactions = true;
        });
        Map mv = {"status": "0"};
        setState(() {
          loading = false;
        });
        return mv;
      } else {
        setState(() {
          this.hash = hash;
          noTransactions = false;
        });

        print("here");
        ScannerWrapper wrapper = new ScannerWrapper();
        await wrapper.getDetails(hash).then((jss) {
          print("checking:" + jss.toString());
          setState(() {
            json = jss;
          });
          jos = jss;
          _check();
          setState(() {
            loading = false;
          });
          return jss;
        });
      }
      return jos;
    });
  }

  _check() async {
    if (json["result"]["status"] == "1" || json["message"] == "NOTOK") {
      await SharedPreferences.getInstance().then((prefs) {
        setState(() {
          transacting = false;
          print("transaction mereged");
          print("check2:" + transacting.toString());
        });
        prefs.setBool("transacting", false);
      });
    }
    if (json["message"] == "NOTOK" || json["result"]["status"] == "0") {
      setState(() {
        print("Transaction failed");
        transacting = false;
        err = true;
      });
      print("err: check" + err.toString());
    }
  }
}
