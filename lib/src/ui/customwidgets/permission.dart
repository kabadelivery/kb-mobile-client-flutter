import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/_static_data/KTheme.dart';
import '../../utils/functions/permissions.dart';

class PermissionsModal extends StatefulWidget {
  const PermissionsModal({super.key});
  @override
  State<PermissionsModal> createState() => _PermissionsModalState();
}

class _PermissionsModalState extends State<PermissionsModal> {
  bool _isRequesting = false;
  final double modalWidth = 340;
  late SharedPreferences prefs;

  // Liste dans l'ordre : Notification, Location, Photos/Media
  final List<_PermItem> _permSequence = [
    _PermItem(name: 'Notifications', permission: Permission.notification),
    _PermItem(name: 'Localisation', permission: Permission.locationWhenInUse),
    // Use photos on iOS, storage on Android. permission_handler provides Permission.photos.
    _PermItem(name: 'Photos & Médias', permission: Permission.photos),
  ];

  Future<void> _requestAllSequentially(BuildContext context) async {
    prefs= await SharedPreferences.getInstance();
    prefs!.setString("_has_accepted_gps", "ok");
    if (_isRequesting) return;
    setState(() => _isRequesting = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ProgressDialog(),
    );

    final Map<String, PermissionStatus> results = {};

    for (final item in _permSequence) {
      await Future.delayed(const Duration(milliseconds: 300));
      PermissionStatus status;
      try {
        if (item.name.toLowerCase().contains('photo') ||
            item.name.toLowerCase().contains('photos') ||
            item.name.toLowerCase().contains('media') ||
            item.permission == Permission.photos) {
          // Utilise ta fonction dédiée pour camera & galerie
          final dynamic photoResult = await requestCameraAndGalleryPermissions();

          // Supporte plusieurs types de retour :
          if (photoResult is PermissionStatus) {
            status = photoResult;
          } else if (photoResult is bool) {
            status = photoResult ? PermissionStatus.granted : PermissionStatus.denied;
          } else {
            // si ta fonction renvoie autre chose (null, map, etc.), essaye de lire un champ, sinon consider denied
            try {
              // si photoResult['status'] existe et ressemble à PermissionStatus
              if (photoResult != null && photoResult is Map && photoResult['status'] is PermissionStatus) {
                status = photoResult['status'] as PermissionStatus;
              } else {
                status = PermissionStatus.denied;
              }
            } catch (_) {
              status = PermissionStatus.denied;
            }
          }
        } else {
          // comportement par défaut pour les autres permissions
          status = await item.permission.request();
        }
      } catch (e) {
        // En cas d'erreur (permission non supportée sur la plateforme), mark as denied
        status = PermissionStatus.denied;
      }

      results[item.name] = status;

      // Update the progress dialog text by using Navigator.pop and show a new one
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // close old progress
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _ProgressDialog(current: item.name, status: status),
        );
      }

      // If permanently denied, propose d'ouvrir les paramètres et arrêter la séquence
      if (status.isPermanentlyDenied) {
        // small wait to let user see
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) Navigator.of(context, rootNavigator: true).pop();

        final open = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("${item.name} bloquée"),
            content: const Text(
              "La permission est bloquée définitivement. Veux-tu ouvrir les paramètres de l'application pour la modifier ?",
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Non")),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Ouvrir paramètres")),
            ],
          ),
        );

        if (open == true) {
          await openAppSettings();
        }
      } else {
        // tiny pause pour fluidité
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }

    // Fermeture du progress dialog s'il est encore ouvert
    if (mounted) Navigator.of(context, rootNavigator: true).pop();

    setState(() => _isRequesting = false);
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: modalWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 30),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                    children: [
                      const TextSpan(text: 'Autorisations '),
                      TextSpan(text: 'nécessaires', style: TextStyle(color: KColors.primaryColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Pour vous offrir la meilleure expérience,\n nous avons besoin d'accéder à certaines fonctionnalités de votre appareil",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: Colors.black54, height: 1.35),
                ),
                const SizedBox(height: 18),
                _PermissionRow(icon: Icons.notifications_none, title: "Notifications", onTap: () {}),
                const SizedBox(height: 10),
                _PermissionRow(icon: Icons.location_on_outlined, title: "Localisation", onTap: () {}),
                const SizedBox(height: 10),
                _PermissionRow(icon: Icons.photo_camera_outlined, title: "Photos & Médias", onTap: () {}),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isRequesting ? null : () => _requestAllSequentially(context).then((_){
                      Navigator.pop(context);
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6334A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.check, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Autoriser tout', style: TextStyle(fontSize: 16,fontWeight:FontWeight.bold,color:Colors.white)),
                    ]),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Plus tard', style: TextStyle(color: Colors.black54,fontWeight:FontWeight.bold)),
                  ),
                ),
              ]),
            ),
            Positioned(
              top: 10,
              left: (modalWidth / 2) - 36,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6334A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: const Center(child: Icon(Icons.shield_outlined, size: 34, color: Colors.white)),
              ),
            ),
            Positioned(
              top: 0,
              left: (modalWidth / 2)-45 ,
              child:Transform.rotate(
                angle: -math.pi / 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                  ),
                  child: const Icon(Icons.notifications_none, size: 14, color: Color(0xFFD6334A)),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: (modalWidth / 2) + 20,
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                  ),
                  child: const Icon(Icons.camera_alt_outlined, size: 14, color: Color(0xFFD6334A)),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: (modalWidth / 2) + 20,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                ),
                child: const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFD6334A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _PermissionRow({required this.icon, required this.title, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD6334A),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child:  Center(child: Icon(icon, size: 18, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
         ]),
      ),
    );
  }
}

class _ProgressDialog extends StatelessWidget {
  final String? current;
  final PermissionStatus? status;
  const _ProgressDialog({this.current, this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final String title = current == null ? "Demande d'autorisations" : "Demande : $current";
    final String sub = status == null
        ? "Connexion..."
        : status!.isGranted
        ? "Autorisé"
        : status!.isPermanentlyDenied
        ? "Bloqué (ouvre paramètres?)"
        : "...";
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 4),
          const CircularProgressIndicator(),
          const SizedBox(width: 18),
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(sub),
          ])
        ]),
      ),
    );
  }
}

class _PermItem {
  final String name;
  final Permission permission;
  const _PermItem({required this.name, required this.permission});
}

void openNotificationModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            // Card
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              width: MediaQuery.of(context).size.width * 0.78,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(height: 30,),
                const Text.rich(
                  TextSpan(
                    text: 'Autoriser les ',
                    children: [
                      TextSpan(text: 'notifications', style: TextStyle(color: Color(0xFFD6334A), fontWeight: FontWeight.bold)),
                    ],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Kaba vous envoie des notifications (suivi de vos commandes ou demandes, informations), pour une meilleure expérience client.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () async {
                    final status = await Permission.notification.request();
                    Navigator.of(context).pop();
                    final snack = status.isGranted ? 'Notifications autorisées' : 'Notifications refusées';
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: KColors.primaryColor ,content: Text(snack)));
                  },
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  label: const Text('Autoriser',style: TextStyle(fontWeight: FontWeight.bold),),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFD13457),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Plus tard', style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold)),
                ),
              ]),
            ),

            // top icon
            Positioned(
              top: 10,
              left: (MediaQuery.of(context).size.width * 0.78) /2- 40,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFCD2247),Color(0xFFC94C66)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
                ),
                child: const Center(child: Icon(Icons.notifications_none, size: 36, color: Colors.white)),
              ),
            ),
            Positioned(
              top: 0,
              left: ((MediaQuery.of(context).size.width * 0.78) / 2)-45 ,
              child:Transform.rotate(
                angle: -math.pi / 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                  ),
                  child: const Icon(Icons.messenger_outline, size: 14, color: Color(0xFFD6334A)),
                ),
              ),
            ),
            Positioned(
              top: 60,
              right: ((MediaQuery.of(context).size.width * 0.78) / 2)-45 ,
              child:Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                  ),
                  child: const Icon(Icons.notifications_none, size: 14, color: Color(0xFFD6334A)),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: ((MediaQuery.of(context).size.width * 0.78) / 2)-55 ,
              child:Image.asset('assets/images/png/start_certif.png',width: 20,),
            ),
            Positioned(
              top: 70,
              left: ((MediaQuery.of(context).size.width * 0.78) / 2)-60 ,
              child:Image.asset('assets/images/png/start_certif.png',width: 20,),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---- Location modal ----------------
void openLocationModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              width: MediaQuery.of(context).size.width * 0.78,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFBFBFBF), width: 1.2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [

                const SizedBox(height: 30),
                const Text.rich(
                  TextSpan(
                    text: 'Autoriser la ',
                    children: [
                      TextSpan(text: 'localisation', style: TextStyle(color: Color(0xFFD6334A), fontWeight: FontWeight.bold)),
                    ],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Kaba a besoin de votre géolocalisation pour vous livrer efficacement et vous afficher les marchands proches de vous.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () async {
                    LocationPermission p = await Geolocator.checkPermission();
                    if (p == LocationPermission.denied) {
                      p = await Geolocator.requestPermission();
                    }
                    if (p == LocationPermission.deniedForever) {
                      // open app settings suggestion
                      Navigator.of(context).pop();
                      if (context.mounted) {
                        final open = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Permission bloquée'),
                            content: const Text('La permission localisation est bloquée. Ouvrir les paramètres ?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Non')),
                              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Paramètres')),
                            ],
                          ),
                        );
                        if (open == true) openAppSettings();
                      }
                      return;
                    }
                    final allowed = (p == LocationPermission.always || p == LocationPermission.whileInUse);
                    Navigator.of(context).pop();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(allowed ? 'Localisation autorisée' : 'Localisation non autorisée')));
                    }
                  },
                  icon: const Icon(Icons.location_on, color: Colors.white),
                  label: const Text('Autoriser',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFD6334A),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Plus tard', style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),),
                ),
              ]),
            ),

            Positioned(
              top: 10,
              left: (MediaQuery.of(context).size.width * 0.78) / 2 - 40,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFCD2247),Color(0xFFC94C66)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
                ),
                child: const Center(child: Icon(Icons.location_on_outlined, size: 36, color: Colors.white)),
              ),
            ),
            Positioned(
              top: 0,
              left: ((MediaQuery.of(context).size.width * 0.78) / 2)-45 ,
              child:Transform.rotate(
                angle: -math.pi / 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                  ),
                  child: const Icon(Icons.home_outlined, size: 14, color: Color(0xFFD6334A)),
                ),
              ),
            ),
            Positioned(
              top: 60,
              right: ((MediaQuery.of(context).size.width * 0.78) / 2)-45 ,
              child:Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                  ),
                  child: const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFD6334A)),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: ((MediaQuery.of(context).size.width * 0.78) / 2)-55 ,
              child:Image.asset('assets/images/png/start_certif.png',width: 20,),
            ),
            Positioned(
              top: 70,
              left: ((MediaQuery.of(context).size.width * 0.78) / 2)-60 ,
              child:Image.asset('assets/images/png/start_certif.png',width: 20,),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---- Photos modal ----------------
void openPhotosModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              width: MediaQuery.of(context).size.width * 0.78,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFBFBFBF), width: 1.2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [

                const SizedBox(height: 30),
                const Text.rich(
                  TextSpan(
                    text: 'Autoriser ',
                    children: [
                      TextSpan(text: 'Photos & Médias', style: TextStyle(color: Color(0xFFD6334A), fontWeight: FontWeight.bold)),
                    ],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                 Text(
                  "Kaba aura accès à certains médias lorsque vous souhaitez vendre quelque chose, modifier votre profil ou télécharger des images dans le cadre d'un service particulier (Ex: Kaba Expédition).",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () async {
                    final status = await requestCameraAndGalleryPermissions();
                    Navigator.of(context).pop();
                    final snack = status ==true ? 'Accès aux photos autorisé' : 'Accès aux photos refusé';
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:KColors.primaryColor,content: Text(snack)));
                  },
                  icon: const Icon(Icons.photo, color: Colors.white),
                  label: const Text('Autoriser',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFD6334A),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Plus tard', style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
            Positioned(
              top: 10,
              left: (MediaQuery.of(context).size.width * 0.78) / 2 - 40,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFCD2247),Color(0xFFC94C66)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
                ),
                child: const Center(child: Icon(Icons.photo, size: 36, color: Colors.white)),
              ),
            ),
            Positioned(
              top: 0,
              left: ((MediaQuery.of(context).size.width * 0.78) / 2)-45 ,
              child:Transform.rotate(
                angle: -math.pi / 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                  ),
                  child: const Icon(Icons.emergency_recording_outlined, size: 14, color: Color(0xFFD6334A)),
                ),
              ),
            ),
            Positioned(
              top: 60,
              right: ((MediaQuery.of(context).size.width * 0.78) / 2)-45 ,
              child:Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                  ),
                  child: const Icon(Icons.camera_alt_outlined, size: 14, color: Color(0xFFD6334A)),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: ((MediaQuery.of(context).size.width * 0.78) / 2)-55 ,
              child:Image.asset('assets/images/png/start_certif.png',width: 20,),
            ),
            Positioned(
              top: 70,
              left: ((MediaQuery.of(context).size.width * 0.78) / 2)-60 ,
              child:Image.asset('assets/images/png/start_certif.png',width: 20,),
            ),
          ],
        ),
      ),
    ),
  );
}
