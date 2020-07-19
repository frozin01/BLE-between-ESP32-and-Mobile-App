import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key key, this.result, this.onTap}) : super(key: key);

  //Result of bluetooth devices
  final ScanResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(result.device.name),
      subtitle: Text(result.device.id.toString()),
      leading: Icon(Icons.devices),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: new EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(result.rssi.toString()),
                Text('dBm'),
              ],
            ),
          ),
        ],
      ),
      onTap: (result.advertisementData.connectable) ? onTap : null,
    );
  }
}
