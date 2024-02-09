import 'package:farm/styles/color_style.dart';
import 'package:farm/widgets/bottom_sheets/add_crop_sheet.dart';
import 'package:farm/widgets/bottom_sheets/pair_hardware_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCropFlow();
        },
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                "Today’s Weather",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ColorStyle.textColor),
              ),
              const SizedBox(height: 20),
              _buildWeatherWidget(),
              const SizedBox(height: 50),
              const Text(
                "Your Crops",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ColorStyle.textColor),
              ),
              const SizedBox(height: 20),
              //_buildEmptyCropsWidget(),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) => _buildCropTileWidget(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showAddCropFlow() async {
    Map<String, dynamic>? cropSettings = await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (BuildContext ctx) {
        return const AddCropSheet();
      },
    );

    if (cropSettings != null && mounted) {
      Future.delayed(const Duration(milliseconds: 500)).then((value) async {
        bool? isPaired = await showModalBottomSheet(
          useRootNavigator: true,
          isScrollControlled: true,
          useSafeArea: true,
          context: context,
          builder: (BuildContext ctx) {
            return const PairHardwareSheet();
          },
        );
      });
    }
  }

  _buildCropTileWidget(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: ColorStyle.secondaryBackgroundColor,
        border:
            Border(left: BorderSide(color: ColorStyle.primaryColor, width: 6)),
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(8),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "My potato crop",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorStyle.textColor),
          ),
          Text("Healthy",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorStyle.lightPrimaryColor))
        ],
      ),
    );
  }

  _buildEmptyCropsWidget() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            child: SvgPicture.asset('assets/svgs/home_image.svg'),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "You currently have no crops added press here to add some",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: ColorStyle.lightTextColor),
          ),
        ),
        SvgPicture.asset('assets/svgs/tutorial_arrow_image.svg'),
      ],
    );
  }

  _buildWeatherWidget() {
    return Container(
      width: double.maxFinite,
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorStyle.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 5,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "21°\tSunny",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.textColor),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                decoration: BoxDecoration(
                    color: ColorStyle.lightTextColor,
                    borderRadius: BorderRadius.circular(6)),
                child: const Text(
                  "10% Rain",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorStyle.backgroundColor),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
