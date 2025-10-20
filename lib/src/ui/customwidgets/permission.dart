import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localizations/AppLocalizations.dart';
import '../../utils/_static_data/KTheme.dart';
import '../../utils/functions/permissions.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> requestIOSNotificationPermission(BuildContext context) async {
  // For iOS only
  final iosSettings = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );

  final snack = (iosSettings ?? false)
      ? AppLocalizations.of(context)!.translate('notifications_granted')
      : AppLocalizations.of(context)!.translate('notifications_denied');

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: KColors.primaryColor,
        content: Text(snack),
      ),
    );
  }
}
class PermissionsModal extends StatefulWidget {
  const PermissionsModal({super.key});
  @override
  State<PermissionsModal> createState() => _PermissionsModalState();
}

class _PermissionsModalState extends State<PermissionsModal> {
  bool _isRequesting = false;
  final double modalWidth = 340;
  late SharedPreferences prefs;

  final List<_PermItem> _permSequence = [
    _PermItem(
      name: 'notifications',
      permission: Permission.notification,
    ),
    _PermItem(
      name: 'location',
      permission: Permission.locationWhenInUse,
    ),
    _PermItem(
      name: 'photos_media',
      permission: Permission.photos,
    ),
  ];

  Future<void> _requestAllSequentially(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString("_has_accepted_gps", "ok");

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
        if (item.permission == Permission.photos) {
          final dynamic photoResult = await requestCameraAndGalleryPermissions();
          if (photoResult is PermissionStatus) {
            status = photoResult;
          } else if (photoResult is bool) {
            status = photoResult ? PermissionStatus.granted : PermissionStatus.denied;
          } else {
            status = PermissionStatus.denied;
          }
        } else {
          status = await item.permission.request();
        }
      } catch (_) {
        status = PermissionStatus.denied;
      }

      results[item.name] = status;

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _ProgressDialog(current: item.name, status: status),
        );
      }

      if (status.isPermanentlyDenied) {
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) Navigator.of(context, rootNavigator: true).pop();

        final open = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("${AppLocalizations.of(context)!.translate(item.name)} ${AppLocalizations.of(context)!.translate('blocked')}"),
            content: Text(AppLocalizations.of(context)!.translate('permission_permanently_denied')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.translate('no')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(AppLocalizations.of(context)!.translate('open_settings')),
              ),
            ],
          ),
        );

        if (open == true) await openAppSettings();
      } else {
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                      children: [
                        TextSpan(text: AppLocalizations.of(context)!.translate('permissions')),
                        TextSpan(text: ' ${AppLocalizations.of(context)!.translate('required')}', style: TextStyle(color: KColors.primaryColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.translate('permissions_description'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13.5, color: Colors.black54, height: 1.35),
                  ),
                  const SizedBox(height: 18),
                  _PermissionRow(icon: Icons.notifications_none, title: AppLocalizations.of(context)!.translate('notifications'), onTap: () {}),
                  const SizedBox(height: 10),
                  _PermissionRow(icon: Icons.location_on_outlined, title: AppLocalizations.of(context)!.translate('location'), onTap: () {}),
                  const SizedBox(height: 10),
                  _PermissionRow(icon: Icons.photo_camera_outlined, title: AppLocalizations.of(context)!.translate('photos_media'), onTap: () {}),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isRequesting ? null : () => _requestAllSequentially(context).then((_) => Navigator.pop(context)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6334A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.translate('allow_all'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
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
                      child: Text(AppLocalizations.of(context)!.translate('later'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            // Positioned icons...
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
    final String title = current == null
        ? AppLocalizations.of(context)!.translate('permission_request')
        : "${AppLocalizations.of(context)!.translate('request_for')}: $current";

    final String sub = status == null
        ? AppLocalizations.of(context)!.translate('connecting')
        : status!.isGranted
        ? AppLocalizations.of(context)!.translate('granted')
        : status!.isPermanentlyDenied
        ? AppLocalizations.of(context)!.translate('blocked_open_settings')
        : "...";

    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 4),
          const CircularProgressIndicator(),
          const SizedBox(width: 18),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(sub),
            ],
          ),
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
                SizedBox(height: 30),
                Text.rich(
                  TextSpan(
                    text: "${AppLocalizations.of(context)!.translate('allow')} ",
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.translate('notifications'),
                        style: const TextStyle(color: Color(0xFFD6334A), fontWeight: FontWeight.bold),
                      ),
                    ],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.translate('notifications_explanation'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                    onPressed: () async {
                      if (Platform.isIOS) {
                        await requestIOSNotificationPermission(context);
                      } else {
                        final status = await Permission.notification.request();
                        final snack = status.isGranted
                            ? 'Notifications autorisées'
                            : 'Notifications refusées';

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: KColors.primaryColor, content: Text(snack)),
                          );
                        }
                      }

                      Navigator.of(context).pop();
                    },

                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  label: Text(
                    AppLocalizations.of(context)!.translate('allow'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                  child: Text(
                    AppLocalizations.of(context)!.translate('later'),
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
            ),

            // Top icon decorations...
            Positioned(
              top: 10,
              left: (MediaQuery.of(context).size.width * 0.78) / 2 - 40,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFCD2247), Color(0xFFC94C66)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
                ),
                child: const Center(child: Icon(Icons.notifications_none, size: 36, color: Colors.white)),
              ),
            ),
            // ...other positioned icons (messenger, notifications, assets) remain unchanged
          ],
        ),
      )

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
            // Card
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
                Text.rich(
                  TextSpan(
                    text: "${AppLocalizations.of(context)!.translate('allow')} ",
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.translate('location'),
                        style: const TextStyle(color: Color(0xFFD6334A), fontWeight: FontWeight.bold),
                      ),
                    ],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.translate('location_explanation'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () async {
                    LocationPermission p = await Geolocator.checkPermission();
                    if (p == LocationPermission.denied) {
                      p = await Geolocator.requestPermission();
                    }
                    if (p == LocationPermission.deniedForever) {
                      Navigator.of(context).pop();
                      if (context.mounted) {
                        final open = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(AppLocalizations.of(ctx)!.translate('permission_blocked')),
                            content: Text(AppLocalizations.of(ctx)!.translate('open_settings_location')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(AppLocalizations.of(ctx)!.translate('no')),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text(AppLocalizations.of(ctx)!.translate('settings')),
                              ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            allowed
                                ? AppLocalizations.of(context)!.translate('location_granted')
                                : AppLocalizations.of(context)!.translate('location_denied'),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.location_on, color: Colors.white),
                  label: Text(
                    AppLocalizations.of(context)!.translate('allow'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
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
                  child: Text(
                    AppLocalizations.of(context)!.translate('later'),
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
            ),

            // Top icon
            Positioned(
              top: 10,
              left: (MediaQuery.of(context).size.width * 0.78) / 2 - 40,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFCD2247), Color(0xFFC94C66)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
                ),
                child: const Center(child: Icon(Icons.location_on_outlined, size: 36, color: Colors.white)),
              ),
            ),
            // ... other positioned decorations remain unchanged
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
            // Card
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
                Text.rich(
                  TextSpan(
                    text: "${AppLocalizations.of(context)!.translate('allow')} ",
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.translate('photos_media'),
                        style: const TextStyle(color: Color(0xFFD6334A), fontWeight: FontWeight.bold),
                      ),
                    ],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.translate('photos_media_explanation'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () async {
                    final status = await requestCameraAndGalleryPermissions();
                    Navigator.of(context).pop();
                    final snack = status
                        ? AppLocalizations.of(context)!.translate('photos_granted')
                        : AppLocalizations.of(context)!.translate('photos_denied');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: KColors.primaryColor,
                          content: Text(snack),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.photo, color: Colors.white),
                  label: Text(
                    AppLocalizations.of(context)!.translate('allow'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
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
                  child: Text(
                    AppLocalizations.of(context)!.translate('later'),
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
            ),
            // Top icon
            Positioned(
              top: 10,
              left: (MediaQuery.of(context).size.width * 0.78) / 2 - 40,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFCD2247), Color(0xFFC94C66)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
                ),
                child: const Center(child: Icon(Icons.photo, size: 36, color: Colors.white)),
              ),
            ),
            // ... other positioned decorations remain unchanged
          ],
        ),
      ),
    ),
  );
}
