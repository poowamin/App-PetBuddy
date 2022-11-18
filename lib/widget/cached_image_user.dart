import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pet_buddy/model/user_model.dart';

class CachedImageUser extends StatelessWidget {
  final double radius;
  final UserModel user;

  const CachedImageUser({
    Key? key,
    required this.radius,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: user.photo,
        imageBuilder: (context, imageProvider) => CircleAvatar(
            radius: radius, backgroundImage: NetworkImage(user.photo)),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: radius,
          child: Text(
            user.name.substring(0, 1),
            style: const TextStyle(fontSize: 25),
          ),
        ),
      );
}
