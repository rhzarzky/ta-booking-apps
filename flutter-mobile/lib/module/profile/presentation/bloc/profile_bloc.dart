import 'package:Appointly/module/profile/repository/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Appointly/module/profile/model/profile_model.dart';
import 'package:meta/meta.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;
  final Logger _logger = Logger();

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<GetProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        // Set token sebelum melakukan request
        if (token != null && token.isNotEmpty) {
          profileRepository.updateToken(token);
        }

        final result = await profileRepository.getProfile();
        emit(ProfileLoaded(result));
      } catch (e) {
        emit(
          ProfileError(
            failure: e.toString(),
          ),
        );
      }
    });

    on<UpdateProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        // Set token sebelum melakukan request
        if (token != null && token.isNotEmpty) {
          profileRepository.updateToken(token);
        }

        final response = await profileRepository.updateProfile(
          event.profile,
          event.imagePath,
        );
        emit(ProfileSuccess(response));
      } catch (e) {
        emit(
          ProfileError(
            failure: e.toString(),
          ),
        );
      }
    });
  }
}
