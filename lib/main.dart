import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'AddressDatabase.dart';
import 'AddressParse.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '地址智能识别',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  TextEditingController addressController = new TextEditingController();
  FocusNode addressFocusNode = new FocusNode();
  Map result = new Map();

  @override
  void initState() {
    super.initState();
    AddressParse.parseArea(AddressDatabase.areaList, null);
  }

  @override
  void dispose() {
    super.dispose();
    addressController.dispose();
    addressFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("地址智能识别"),
      ),
      body: GestureDetector(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                physics: ClampingScrollPhysics(),
                children: <Widget>[
                  buildAddressTextField(),
                  buildButton(),
                  buildResult(),
                ],
              ),
            ),
            Container(
              height: 45,
              child: buildBottomBtn(),
            )
          ],
        ),
        onTap: () {
          addressFocusNode.unfocus();
        },
      ),
    );
  }

  Widget buildAddressTextField() {
    return Container(
      height: 120,
      margin: EdgeInsets.fromLTRB(10, 10, 10, 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: TextField(
        controller: addressController,
        focusNode: addressFocusNode,
        cursorColor: Theme.of(context).primaryColor,
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
          border: InputBorder.none,
          hintText: "请输入地址",
          hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 1,
            ),
          ),
        ),
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
    );
  }

  Widget buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 50,
          width: (MediaQuery.of(context).size.width - 100) / 2,
          margin: EdgeInsets.only(right: 20),
          child: RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                side: BorderSide(
                    color: Theme.of(context).primaryColor, width: 0.5)),
            color: Colors.white,
            child: Text("清除",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 17,
                )),
            onPressed: () {
              addressController.text = "";
            },
          ),
        ),
        Container(
          height: 50,
          width: (MediaQuery.of(context).size.width - 100) / 2,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                side: BorderSide(
                    color: Theme.of(context).primaryColor, width: 0.5)),
            color: Colors.white,
            child: Text("粘贴",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 17,
                )),
            onPressed: () async {
              addressFocusNode.unfocus();
              ClipboardData clipboardData =
                  await Clipboard.getData(Clipboard.kTextPlain);
              addressController.text += clipboardData.text;
            },
          ),
        )
      ],
    );
  }

  Widget buildResult() {
    return Container(
        margin: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "姓名：" + (isEmpty(result["name"]) ? "" : result["name"]),
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "手机：" + (isEmpty(result["mobile"]) ? "" : result["mobile"]),
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "电话：" + (isEmpty(result["phone"]) ? "" : result["phone"]),
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "省份：" +
                  (isEmpty(result["province"]) ? "" : result["province"]),
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "城市：" + (isEmpty(result["city"]) ? "" : result["city"]),
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "地区：" + (isEmpty(result["area"]) ? "" : result["area"]),
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "详细地址：" + (isEmpty(result["addr"]) ? "" : result["addr"]),
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "邮编：" +
                  (isEmpty(result["zip_code"]) ? "" : result["zip_code"]),
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "detail(不知道是什么，一般没有)：" + (isEmpty(result["detail"]) ? "" : result["detail"]),
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "result(不知道是什么，一般没有)：" + (isEmpty(result["result"]) ? "" : result["result"]),
              style: TextStyle(fontSize: 18),
            ),
          ],
        ));
  }

  Widget buildBottomBtn() {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width,
      child: FlatButton(
          shape: RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(0))),
          color: Theme.of(context).primaryColor,
          colorBrightness: Brightness.dark,
          onPressed: () {
            addressFocusNode.unfocus();
            if (addressController.text == '') {
              print("未输入任何文字！");
            } else {
              result = AddressParse.parse(addressController.text);
              print(result);
              setState(() {});
            }
          },
          child: Text(
            "识别",
            style: TextStyle(
              fontSize: 17,
            ),
          )),
    );
  }

  bool isEmpty(var Object) {
    if (Object is String) {
      return Object == null || Object == "";
    } else {
      return Object == null;
    }
  }
}
