

import 'package:flutter/material.dart';

bool isMobileMode({required BuildContext context}) {
  if (MediaQuery.of(context).size.width < 650) {
    return true;
  } else {
    return false;
  }
}