import 'package:flutter/cupertino.dart';

import '../../../../../shared/presentation/theme/extra_colors.dart';
import '../../../../../shared/utils/navigation.dart';
import '../../../../../shared/widgets/clickable.dart';
import '../../../../../src/profile/presentation/interface/pages/profile.dart';
import '../../../domain/entities/chef.dart';

class ChefListWidget extends StatelessWidget {
  final List<Chef> chefs;

  const ChefListWidget({
    required this.chefs,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: chefs.length > 4 ? 4 : chefs.length,
        itemBuilder: (context, index) {
          final String chefName = chefs[index].name;
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.23,
            child: Clickable(
              onClick: () => NavigationHelper.navigateTo(
                context,
                ProfilePage(chefID: chefs[index].id),
              ),
              child: Column(
                children: [
                  const Icon(
                    CupertinoIcons.person_alt_circle,
                    color: ExtraColors.darkGrey,
                    size: 80,
                  ),
                  Text(
                    chefName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
