import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_matcher/data/profile/domain/profile_domain.dart';
import 'package:sport_matcher/ui/core/theme/app_theme.dart';
import 'package:sport_matcher/ui/core/ui/buttons/async_rounded_button/async_rounded_button.dart';
import 'package:sport_matcher/ui/core/ui/collections/chips_collection_view.dart';
import 'package:sport_matcher/ui/core/ui/text_fields/plain_text_field.dart';
import 'package:sport_matcher/ui/core/ui/texts/title_medium_text.dart';
import 'package:sport_matcher/ui/profile/profile_photo/widgets/profile_photo_screen.dart';
import 'package:sport_matcher/ui/profile/widgets/profile_form_fields_view_model.dart';

class ProfileFormFieldsView extends StatefulWidget {
  final String buttonTitle;
  final VoidCallback? onSaved;
  final ValueChanged<String>? onSaveFailed;
  final ProfileSaveAction? saveProfile;
  final ProfileDomain? initialProfile;

  const ProfileFormFieldsView({
    super.key,
    required this.buttonTitle,
    this.onSaved,
    this.onSaveFailed,
    this.saveProfile,
    this.initialProfile,
  });

  @override
  State<ProfileFormFieldsView> createState() => _ProfileFormFieldsViewState();
}

class _ProfileFormFieldsViewState extends State<ProfileFormFieldsView> {
  late final _viewModel = ProfileFormFieldsViewModel(
    buttonTitle: widget.buttonTitle,
    onSaved: widget.onSaved,
    onSaveFailed: widget.onSaveFailed,
    saveProfile: widget.saveProfile,
    initialProfile: widget.initialProfile,
  );

  @override
  void initState() {
    super.initState();
    _viewModel.onStateChanged = () {
      setState(() {});
    };
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.horizontalAndBottomPadding(context),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: AppTheme.columnVerticalPaddings(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppTheme.columnSpacingMedium,
                  children: [
                    Center(child: _photoPlaceholder()),
                    PlainTextField(
                      controller: _viewModel.nameTextController,
                      title: "Name",
                      validator: _viewModel.nameValidator,
                      textCapitalization: TextCapitalization.words,
                      autocorrect: false,
                      enableSuggestions: false,
                    ),
                    const TitleMediumText(text: "Select your favorite sports"),
                    ChipsCollectionView(
                      items: _viewModel.displayActivities,
                      onSelectionChanged: _viewModel.updateActivitiesByDisplayName,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AsyncRoundedButton(
            buttonTitle: _viewModel.buttonTitle,
            onPressed: _viewModel.buttonAction,
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    final imagePath = _viewModel.profileImagePath;
    Widget content;
    if (imagePath case final path?) {
      content = ProfilePhotoView(imagePath: path);
    } else {
      content = Padding(
        padding: const EdgeInsets.all(24.0),
        child: SvgPicture.asset(
          'lib/ui/profile/create_profile/assets/photo_placeholder.svg',
          fit: BoxFit.contain,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: OutlinedButton(
          onPressed: _viewModel.pickImage,
          style: OutlinedButton.styleFrom(
            padding:
                imagePath == null ? const EdgeInsets.all(48) : EdgeInsets.zero,
            side: BorderSide(color: AppTheme.primaryColor, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: Size.zero,
          ),
          child: content,
        ),
      ),
    );
  }
}
