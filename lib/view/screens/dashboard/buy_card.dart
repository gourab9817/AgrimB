import 'package:agrimb/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/localization_extension.dart';

List<Map<String, String>> getBestDealsList(BuildContext context) {
  return [
    {'image': AppAssets.wheat, 'title': context.l10n('wheat')},
    {'image': AppAssets.millet, 'title': context.l10n('millet')},
    {'image': AppAssets.vagetables, 'title': context.l10n('vegetables')},
    {'image': AppAssets.onion, 'title': context.l10n('onion')},
    {'image': AppAssets.tomato, 'title': context.l10n('tomato')},
    // Add more deals as needed
  ];
}
