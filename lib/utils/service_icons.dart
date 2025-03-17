// lib/utils/service_icons.dart

import 'package:flutter/material.dart';

class ServiceIcons {
  static Widget getServiceIcon(String serviceName, {double size = 32, Color? color}) {
    color ??= const Color(0xFF026DFE);
    
    // Map service names to their respective icons - matches Firebase service names exactly
    final Map<String, IconData> serviceIconMap = {
      'oil change': Icons.oil_barrel,
      'wheel alignment': Icons.tire_repair,
      'battery replacement': Icons.battery_charging_full,
      'air conditioning': Icons.ac_unit,
      'tire replacement': Icons.tire_repair,
      'engine repair': Icons.engineering,
      'brake service': Icons.do_not_step,
      'car wash': Icons.local_car_wash,
      'diagnostics': Icons.build,
      'electrical repair': Icons.electrical_services,
      'transmission service': Icons.settings,
      'exhaust system': Icons.air,
      'suspension': Icons.height,
      'steering': Icons.directions_car,
      'cooling system': Icons.whatshot,
      'fuel system': Icons.local_gas_station,
      'inspection': Icons.search,
      'maintenance': Icons.handyman,
      'paintwork': Icons.format_paint,
      'detailing': Icons.cleaning_services,
      'ac filter replacement': Icons.filter_alt,
      'brake fluid replacement': Icons.opacity,
      'child seat installation': Icons.child_care,
      'clutch replacement': Icons.swap_horiz,
      'dashboard repair': Icons.dashboard,
      'door lock repair': Icons.lock,
      'engine diagnostics': Icons.network_check,
      'exhaust repair': Icons.air,
      'fuel system cleaning': Icons.cleaning_services,
      'full vehicle inspection': Icons.fact_check,
      'gearbox repair': Icons.settings_applications,
      'headlight restoration': Icons.light_mode,
      'hood repair': Icons.car_repair,
      'interior detailing': Icons.chair_alt,
      'key programming': Icons.key,
      'leather seat repair': Icons.event_seat,
      'paint touchup': Icons.format_paint,
      'power steering repair': Icons.control_camera,
      'radiator service': Icons.waves,
      'rearview camera installation': Icons.camera_rear,
      'side mirror replacement': Icons.flip_camera_android,
      'spark plug replacement': Icons.electric_bolt,
      'suspension repair': Icons.height,
      'timing belt replacement': Icons.timer,
      'undercoating': Icons.format_color_fill,
      'windshield replacement': Icons.crop_landscape,
    };

    // Custom handling for specific services that need image assets
    if (serviceName.toLowerCase() == 'brake inspection') {
      return Image.asset(
        'assets/images/brake.png',
        width: size,
        height: size,
      );
    }

    // Get the icon from the map or use default
    final IconData iconData = serviceIconMap[serviceName.toLowerCase()] ?? Icons.car_repair;

    return Icon(
      iconData,
      color: color,
      size: size,
    );
  }

  // Helper method to check if a service has an icon
  static bool hasIcon(String serviceName) {
    final Map<String, IconData> serviceIconMap = {
      // Same map as above
    };
    return serviceIconMap.containsKey(serviceName.toLowerCase());
  }

  // Optional: Get all services that have icons defined
  static List<String> getServicesWithIcons() {
    return [
      'Oil Change',
      'Wheel Alignment',
      'Brake Inspection',
      'Battery Replacement',
      'Air Conditioning',
      'Tire Replacement',
      'Engine Repair',
      'Brake Service',
      'Car Wash',
      'Diagnostics',
      'Electrical Repair',
      'Transmission Service',
      'Exhaust System',
      'Suspension',
      'Steering',
      'Cooling System',
      'Fuel System',
      'Inspection',
      'Maintenance',
      'Paintwork',
      'Detailing',
      'Ac Filter Replacement',
      'Brake Fluid Replacement',
      'Child Seat Installation',
      'Clutch Replacement',
      'Dashboard Repair',
      'Door Lock Repair',
      'Engine Diagnostics',
      'Exhaust Repair',
      'Fuel System Cleaning',
      'Full Vehicle Inspection',
      'Gearbox Repair',
      'Headlight Restoration',
      'Hood Repair',
      'Interior Detailing',
      'Key Programming',
      'Leather Seat Repair',
      'Paint Touchup',
      'Power Steering Repair',
      'Radiator Service',
      'Rearview Camera Installation',
      'Side Mirror Replacement',
      'Spark Plug Replacement',
      'Suspension Repair',
      'Timing Belt Replacement',
      'Undercoating',
      'Windshield Replacement',
    ];
  }
}