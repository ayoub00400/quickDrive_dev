import 'package:flutter/material.dart';
import 'package:taxi_driver/app/utils/var/var_app.dart';

class SendScheduledRideOffreBottomSheet {
  Future<void> showOffreInputDialog() async {
    await showBottomSheet(
        context: getContext(),
        builder: (context) {
          return Container(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text(
                  'Send an offre',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Offre',
                    border: OutlineInputBorder(),
                  ),
                )
              ]));
        });
  }
}
