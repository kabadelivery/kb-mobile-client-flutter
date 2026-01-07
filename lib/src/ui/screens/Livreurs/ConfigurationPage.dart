import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../models/Besoin_Livreurs/deliveryconfig.dart';
import 'Recap.dart';

class DeliveryConfigurationPage extends StatefulWidget {
  final String pickupAddress;
  final double latitude;
  final double longitude;

  const DeliveryConfigurationPage({
    super.key,
    required this.pickupAddress,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<DeliveryConfigurationPage> createState() => _DeliveryConfigurationPageState();
}

class _DeliveryConfigurationPageState extends State<DeliveryConfigurationPage> {
  int deliveryCount = 1;
  List<DeliveryConfig> deliveries = [DeliveryConfig()];
  final ImagePicker _picker = ImagePicker();
  final List<String> lomeQuartiers = ["Adidogomé", "Agoè", "Bè", "Dékon", "Hédzranawoé", "Lomé II", "Tokoin", "Baguid"];

  @override
  void initState() {
    super.initState();
    deliveries[0].startAddress = widget.pickupAddress;
  }

  void _updateCount(int count) {
    if (count < 1 || count > 10) return;
    setState(() {
      deliveryCount = count;
      if (count > deliveries.length) {
        deliveries.addAll(List.generate(count - deliveries.length, (_) => DeliveryConfig()..startAddress = widget.pickupAddress));
      } else {
        deliveries = deliveries.sublist(0, count);
      }
    });
  }

  Future<void> _pickImage(int dIndex, int pIndex) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => deliveries[dIndex].photos[pIndex] = File(image.path));
    }
  }

  void _openMapPicker(int index) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MapPickerModal(initialLat: widget.latitude, initialLon: widget.longitude),
    );
    if (result != null) {
      setState(() {
        deliveries[index].destinationAddress = result['address'];
        deliveries[index].destLatitude = result['lat'];
        deliveries[index].destLongitude = result['lon'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCountSelectorCard(),
                  const SizedBox(height: 16),
                  ...deliveries.asMap().entries.map((e) => _buildDeliveryCard(e.key, e.value)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomConfirmation(),
        ],
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFD61C4E), Color(0xFFB01C3A)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 15),
          const Text("Configuration", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Text("1/1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- TOP SELECTOR CARD ---
  Widget _buildCountSelectorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFFFF1F3), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.inventory_2, color: Color(0xFFD61C4E), size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nombre de livraisons", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text("Configurez chaque livraison ci-dessous", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(4, (i) {
              int val = i + 1;
              bool isSelected = deliveryCount == val;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _updateCount(val),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD61C4E) : Colors.white,
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text("$val", style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleBtn(Icons.remove, () => _updateCount(deliveryCount - 1)),
              Container(
                width: 150,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text("$deliveryCount", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              ),
              _circleBtn(Icons.add, () => _updateCount(deliveryCount + 1)),
            ],
          )
        ],
      ),
    );
  }

  // --- MAIN DELIVERY CARD ---
  Widget _buildDeliveryCard(int index, DeliveryConfig config) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: config.isExpanded ? const Color(0xFFFFF8F9) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFDDE2), width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: const Color(0xFFD61C4E), radius: 15, child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Livraison 1", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("A configurer", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => config.isExpanded = !config.isExpanded),
                  child: Text(config.isExpanded ? "Réduire" : "Agrandir", style: const TextStyle(color: Color(0xFFD61C4E), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          if (config.isExpanded) ...[
            const Divider(color: Color(0xFFFFDDE2), thickness: 1, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(Icons.location_on_outlined, "Adresse de départ"),
                  _inputField(widget.pickupAddress, isPink: true, readOnly: true, suffix: Icons.edit_outlined),

                  const SizedBox(height: 16),
                  _label(Icons.location_on, "Adresse d'arrivée"),
                  Row(
                    children: [
                      _toggleChip("GPS", config.useGps, () => setState(() => config.useGps = true), Icons.map),
                      const SizedBox(width: 10),
                      _toggleChip("Quartier", !config.useGps, () => setState(() => config.useGps = false), Icons.home_work),
                    ],
                  ),

                  const SizedBox(height: 12),
                  config.useGps
                      ? _blueBtn(config.destinationAddress.isEmpty ? "Sélectionner sur la carte" : config.destinationAddress, Icons.map_outlined, () => _openMapPicker(index))
                      : _dropdownField("Sélectionner un quartier", lomeQuartiers, (v) => setState(() => config.destinationAddress = v!)),

                  const SizedBox(height: 16),
                  _label(null, "Détails de l'adresse"),
                  _textArea("Ex : à côté de la Pharmacie, portail bleu...", (v) => config.addressDetails = v),

                  const SizedBox(height: 12),
                  _priceBadge("Frais de livraison : 2 500 FCFA"),

                  const SizedBox(height: 16),
                  _label(Icons.phone_outlined, "N° Téléphone à joindre à la livraison"),
                  _inputField("+228 XX XX XX XX", onChanged: (v) => config.phoneNumber = v),

                  const SizedBox(height: 16),
                  _label(Icons.access_time, "Instantanée ou Programmée ?"),
                  Row(
                    children: [
                      _toggleChip("Instantanée", !config.isScheduled, () => setState(() => config.isScheduled = false)),
                      const SizedBox(width: 10),
                      _toggleChip("Programmée", config.isScheduled, () => setState(() => config.isScheduled = true)),
                    ],
                  ),
                  if (config.isScheduled) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _inputField("jj/mm/aaaa", onChanged: (v) => config.scheduledDate = v)),
                        const SizedBox(width: 10),
                        Expanded(child: _inputField("-- : --", onChanged: (v) => config.scheduledTime = v)),
                      ],
                    )
                  ],

                  const SizedBox(height: 16),
                  _label(Icons.person_outline, "Boutique ou particulier ?"),
                  Row(
                    children: [
                      _toggleChip("Particulier", !config.isShop, () => setState(() => config.isShop = false), Icons.person),
                      const SizedBox(width: 10),
                      _toggleChip("Boutique", config.isShop, () => setState(() => config.isShop = true), Icons.store),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _label(Icons.inventory_2_outlined, "Nature du colis"),
                  _textArea("Décrivez le contenu du colis (ex: Documents, produits alimentaires ..etc )", (v) => config.packageNature = v),

                  const SizedBox(height: 16),
                  _label(Icons.camera_alt_outlined, "Photos du colis"),
                  const Text("1e photo obligatoire", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(3, (i) => _photoBox(index, i, config.photos[i])),
                  ),

                  const SizedBox(height: 24),
                  _buildPaymentOptions(config),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  // --- PAYMENT SECTION ---
  Widget _buildPaymentOptions(DeliveryConfig config) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.credit_card, color: Color(0xFFD61C4E), size: 20),
              SizedBox(width: 8),
              Text("Options de paiements du client", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Montant à récupérer ?", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            children: [
              _toggleChip("Non, aucun montant", !config.recoverAmount, () => setState(() => config.recoverAmount = false)),
              const SizedBox(width: 10),
              _toggleChip("Oui, récupérer", config.recoverAmount, () => setState(() => config.recoverAmount = true)),
            ],
          ),
          if (config.recoverAmount) ...[
            const SizedBox(height: 12),
            const Text("Montant à récupérer (FCFA)", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            _inputField("Ex : 50000", onChanged: (v) => config.amountToRecover = v),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFFFF1F3), borderRadius: BorderRadius.circular(8)),
              child: const Text("Ce montant sera envoyé dans votre portefeuille après livraison", style: TextStyle(color: Color(0xFFD61C4E), fontSize: 11)),
            ),
          ],
          const SizedBox(height: 16),
          const Text("Frais de livraison déjà payé ?", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          _paymentTile("Non, paiement à la livraison", "Le livreur récupère les frais", config.paymentType == 0, () => setState(() => config.paymentType = 0)),
          _paymentTile("Oui, débiter mon portefeuille", "Paiement immédiat", config.paymentType == 1, () => setState(() => config.paymentType = 1)),
          _paymentTile("Oui, à la récupération du colis", "", config.paymentType == 2, () => setState(() => config.paymentType = 2)),
        ],
      ),
    );
  }

  // --- REUSABLE UI HELPERS ---
  Widget _circleBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)), child: Icon(icon, color: Colors.black, size: 20)),
  );

  Widget _label(IconData? icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [if (icon != null) Icon(icon, size: 16, color: const Color(0xFFD61C4E)), if (icon != null) const SizedBox(width: 6), Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))]),
  );

  Widget _inputField(String hint, {bool readOnly = false, bool isPink = false, IconData? suffix, Function(String)? onChanged}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: isPink ? Border.all(color: const Color(0xFFD61C4E).withOpacity(0.3)) : null),
    child: TextField(readOnly: readOnly, onChanged: onChanged, decoration: InputDecoration(hintText: hint, border: InputBorder.none, suffixIcon: suffix != null ? Icon(suffix, color: const Color(0xFFD61C4E), size: 18) : null)),
  );

  Widget _toggleChip(String label, bool isSelected, VoidCallback onTap, [IconData? icon]) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10), border: Border.all(color: isSelected ? const Color(0xFFD61C4E) : Colors.grey.shade300)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 16, color: isSelected ? const Color(0xFFD61C4E) : Colors.grey),
            if (icon != null) const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isSelected ? const Color(0xFFD61C4E) : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
          ],
        ),
      ),
    ),
  );

  Widget _paymentTile(String title, String sub, bool isSelected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? const Color(0xFFD61C4E) : Colors.grey.shade300)),
      child: Row(
        children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: const Color(0xFFD61C4E), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    ),
  );

  Widget _photoBox(int dIndex, int pIndex, File? file) => Expanded(
    child: GestureDetector(
      onTap: () => _pickImage(dIndex, pIndex),
      child: Container(
        height: 80, margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12)),
        child: file == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.upload_outlined, color: Colors.grey), Text(pIndex == 0 ? "Obligatoire" : "Optionnel", style: const TextStyle(fontSize: 10, color: Colors.grey))]) : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file, fit: BoxFit.cover)),
      ),
    ),
  );

  Widget _blueBtn(String t, IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF2E7DFF), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 10), Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)]),
    ),
  );

  Widget _priceBadge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xFFFFF1F3), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD61C4E).withOpacity(0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.circle, size: 6, color: Color(0xFFD61C4E)), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Color(0xFFD61C4E), fontWeight: FontWeight.bold, fontSize: 13))]),
  );

  Widget _textArea(String hint, Function(String) onC) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
    child: TextField(maxLines: 3, onChanged: onC, decoration: InputDecoration(hintText: hint, border: InputBorder.none, hintStyle: const TextStyle(fontSize: 13))),
  );

  Widget _dropdownField(String h, List<String> i, Function(String?) onC) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(hint: Text(h), isExpanded: true, items: i.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onC)),
  );

  Widget _buildBottomConfirmation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: SafeArea(child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD61C4E), minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RecapPage(deliveries: deliveries))),
        child: Text("Confirmer la demande ($deliveryCount livraison${deliveryCount > 1 ? 's' : ''})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      )),
    );
  }
}

// Map Picker (Remains the same functional component)
class _MapPickerModal extends StatefulWidget {
  final double initialLat, initialLon;
  const _MapPickerModal({required this.initialLat, required this.initialLon});
  @override State<_MapPickerModal> createState() => _MapPickerModalState();
}
class _MapPickerModalState extends State<_MapPickerModal> {
  mapbox.MapboxMap? _map; String _address = "Déplacez pour choisir..."; mapbox.Point? _point;
  @override Widget build(BuildContext context) {
    return Container(height: MediaQuery.of(context).size.height * 0.8, decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))), child: Stack(children: [
      ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), child: mapbox.MapWidget(onMapCreated: (c) => _map = c, onCameraChangeListener: (p) async {
        final pos = await _map!.getCameraState(); _point = pos.center;
        final res = await http.get(Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${_point!.coordinates.lat}&lon=${_point!.coordinates.lng}'), headers: {'User-Agent': 'FlutterApp'});
        if (res.statusCode == 200) setState(() => _address = jsonDecode(res.body)['display_name'].split(',')[0]);
      }, styleUri: mapbox.MapboxStyles.MAPBOX_STREETS)),
      const Center(child: Icon(Icons.location_on, color: Colors.red, size: 40)),
      Positioned(bottom: 20, left: 20, right: 20, child: Column(children: [
        Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Text(_address, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD61C4E), minimumSize: const Size(double.infinity, 50)), onPressed: () => Navigator.pop(context, {'address': _address, 'lat': _point!.coordinates.lat, 'lon': _point!.coordinates.lng}), child: const Text("Confirmer", style: TextStyle(color: Colors.white)))
      ]))
    ]));
  }
}