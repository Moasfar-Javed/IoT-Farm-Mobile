import 'package:farm/styles/color_style.dart';
import 'package:farm/widgets/buttons/custom_rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PairHardwareSheet extends StatefulWidget {
  const PairHardwareSheet({super.key});

  @override
  State<PairHardwareSheet> createState() => _PairHardwareSheetState();
}

class _PairHardwareSheetState extends State<PairHardwareSheet> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            minHeight: MediaQuery.of(context).size.height * 0.7),
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              color: ColorStyle.backgroundColor,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          const Text(
                            "Pair Leaf 1.0 Hardware",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: ColorStyle.textColor),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          SvgPicture.asset('assets/svgs/pair_hardware_image.svg')
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: CustomRoundedButton(
                      "Pair Hardware",
                      () {
                        Navigator.of(context).pop(true);
                      },
                      borderColor: ColorStyle.whiteColor,
                      buttonBackgroundColor: ColorStyle.whiteColor,
                      textColor: ColorStyle.blackColor,
                      waterColor: Colors.black12,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
