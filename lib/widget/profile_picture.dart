import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePic extends StatelessWidget {
  final String imageUrl;
  const ProfilePic({
    Key? key,
    required this.imageUrl,
    required this.updateImage,
  }) : super(key: key);
  final VoidCallback updateImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
     clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(70),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
                width: 40,
                height: 40,
                imageUrl: imageUrl,
                errorWidget: (context, url, error) => const CircleAvatar(
                      backgroundImage:
                          AssetImage("assets/images/placeholder.jpg"),
                    )),
          ),
          Positioned(
            right: -16,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                onPressed: () {
                  updateImage();
                },
                child: SvgPicture.asset("assets/icons/Camera Icon.svg"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
