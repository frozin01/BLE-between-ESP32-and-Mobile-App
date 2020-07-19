import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key key, this.device}) : super(key: key);

  //Device
  final BluetoothDevice device;

  //Characteristic UUID of device (same with arduino ide program)
  static String charUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  //Ngubah data yang dibaca device
  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  //Read data dan menampilkannya
  Widget _myService(List<BluetoothService> services) {
    Stream<List<int>> stream;

    //cek characterUUID
    services.forEach((service) {
      service.characteristics.forEach((character) {
        if (character.uuid.toString() == charUUID) {
          character.setNotifyValue(!character.isNotifying);
          stream = character.value;
        }
      });
    });
    return Container(
      child: StreamBuilder<List<int>>(
          stream: stream,
          builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
            if (snapshot.hasError) return Text('Error : ${snapshot.error}');
            if (snapshot.connectionState == ConnectionState.active) {
              var currentValue = _dataParser(snapshot.data);             
              return Center(
                child: Text(
                  '$currentValue CM',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              );
            } else {
              return Text('');
            }
          }),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (context, snapshot) {
              VoidCallback onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = '';
                  break;
              }
              return FlatButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        .copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[

          //Device dan keterangannya
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (context, snapshot) => ListTile(
              leading: (snapshot.data == BluetoothDeviceState.connected)
                  ? Icon(Icons.bluetooth_connected)
                  : Icon(Icons.bluetooth_disabled),
              title:
                  Text('Device is ${snapshot.data.toString().split('.')[1]}.'),
              subtitle: Text('${device.id}'),
            ),
          ),

          //Read data
          StreamBuilder<bool>(
              stream: device.isDiscoveringServices,
              initialData: false,
              builder: (context, snapshot) => IndexedStack(
                    index: snapshot.data ? 1 : 0,
                    children: <Widget>[
                      ListTile(
                        title: RaisedButton(
                          child: Text("Read Data"),
                          onPressed: () => device.discoverServices(),
                        ),
                      )
                    ],
                  )),
                  
          //Tampilkan Data
          StreamBuilder<List<BluetoothService>>(
            stream: device.services,
            initialData: [],
            builder: (context, snapshot) {
              return _myService(snapshot.data);
            },
          ),
        ],
      ),
    );
  }
}
