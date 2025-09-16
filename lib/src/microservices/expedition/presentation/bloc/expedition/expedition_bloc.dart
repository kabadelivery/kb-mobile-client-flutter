import 'dart:io';

import 'package:KABA/src/microservices/expedition/data/expedition/remote_data_source.dart';
import 'package:KABA/src/microservices/expedition/domain/expedition/repo.dart';
import 'package:KABA/src/microservices/expedition/presentation/bloc/estimation/estimation_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

import '../../../../../models/CustomerModel.dart';
import '../../../../../models/DeliveryAddressModel.dart';
import '../../../../../utils/functions/CustomerUtils.dart';
import '../../../../kaba_chine/usecases/order/upload_image.dart';
import '../../../data/expedition/create_expedition_model.dart';
import '../../../data/expedition/expedition_model.dart';
import '../../../data/expedition/line_model.dart';
import '../../../data/expedition/line_pricing_calculate_model.dart';
import '../../../data/expedition/negociation_model.dart';
import '../../../data/expedition/package_model.dart';
import '../../../usecases/calculate_shipping_pricing.dart';
import '../../../usecases/createNegociation.dart';
import '../../../usecases/create_expedition.dart';
import '../../../usecases/getUserExpedition.dart';
import '../../../usecases/get_shipping_lines.dart';
import '../../../usecases/uploadImage.dart';

part 'expedition_event.dart';
part 'expedition_state.dart';

class ExpeditionBloc extends Bloc<ExpeditionEvent, ExpeditionState> {
  ExpeditionBloc() : super(ExpeditionInitial()) {
    on<GetShippingLinesEvent>(_onGetShippingLines);
    on<CalculateShippingLinePricingEvent>(_onCalculatePricing);
    on<CreateExpeditionEvent>(_onCreateExpedition);
    on<GetUserExpeditionEvent>(_onGetUserExpedition);
    on<CreateNegociationEvent>(_onCreateNegociation);
    on<AddPackageEvent>(_onAddPackage);
    on<RemovePackageEvent>(_onRemovePackage);
    on<ExpandPackageWidgetAction>(_onExpand);
    on<AddPhotoEvent>(_onAddPhoto);
    on<ChangeRecipientAddressEvent>(_onChangeRecipientAddress);
    on<ChangeDescriptionEvent>(_onChangeDescription);
    on<ChangeWeightEvent>(_onChangeWeight);
    on<ChooseArrivalTownEvent>(_onChooseArrivalTown);
    on<ChooseDepartureTownEvent>(_onChooseDepartureTown);
    on<ExpeditionInitialEvent>(_onExpeditionInitial);
    on<SetPackageCountEvent>(_onSetPackageCount);
    on<ChangeRecipientStringAddressEvent>(_onChangeRecipientStringAddress);
    on<getAvailableLines>(_onGetAvailableLines);
    on<chooseShippingMethod>(_chooseShippingMethod);
    on<chooseShippingMethodAddressType>(_chooseShippingMethodAddressType);
    on<chooseFetchDateEvent>(_chooseFetchDate);
    on<chooseFetchTimeEvent>(_chooseFetchTime);
    on<enterRecipientPhoneNumber>(_enterRecipientPhoneNumber);
    on<enterSendPhoneNumber>(_enterSendPhoneNumber);
    on<chooseStarEvent>(_chooseStar);
    on<chooseLikableItem>(_chooseLikable);
  }

  Future<void> _onGetShippingLines(
      GetShippingLinesEvent event,
      Emitter<ExpeditionState> emit,
      ) async {
    emit(ExpeditionLoading());
    try {
      GetShippingLines getShippingLinesUseCase = GetShippingLines(ExpeditionRepositoryImpl(ExpeditionRemoteDataSourceImpl()));
      final lines = await getShippingLinesUseCase(
        customerToken: event.customerToken,
      );
      emit(ShippingLinesLoaded(lines));
    } catch (e) {
      emit(ExpeditionError(e.toString()));
    }
  }

  Future<void> _onCalculatePricing(
      CalculateShippingLinePricingEvent event,
      Emitter<ExpeditionState> emit,
      ) async {
    emit(ExpeditionLoading());
    try {
      CalculateShippingLinePricing calculatePricingUseCase = CalculateShippingLinePricing(ExpeditionRepositoryImpl(ExpeditionRemoteDataSourceImpl()));
      final result = await calculatePricingUseCase(
        queryParameters: event.queryParameters,
        customerToken: event.customerToken,
      );
      emit(LinePricingCalculated(result));
    } catch (e) {
      emit(ExpeditionError(e.toString()));
    }
  }

  Future<void> _onCreateExpedition(
      CreateExpeditionEvent event,
      Emitter<ExpeditionState> emit,
      ) async {
      emit(ExpeditionCreated(expedition:event.createExpedition));
  }

  Future<void> _onGetUserExpedition(
      GetUserExpeditionEvent event,
      Emitter<ExpeditionState> emit,
      ) async {
    emit(ExpeditionLoading());
    try {
      CustomerModel customerModel = await CustomerUtils.getCustomer();
      GetUserExpedition getUserExpeditionUseCase = GetUserExpedition(ExpeditionRepositoryImpl(ExpeditionRemoteDataSourceImpl()));
      final expeditions = await getUserExpeditionUseCase(
        customerToken: customerModel.token!,
      );
      emit(UserExpeditionsLoaded(expeditions));
    } catch (e) {
      emit(ExpeditionError(e.toString()));
    }
  }

  Future<void> _onCreateNegociation(
      CreateNegociationEvent event,
      Emitter<ExpeditionState> emit,
      ) async {
    emit(ExpeditionLoading());
    try {
      CreateNegociation createNegociationUseCase = CreateNegociation(ExpeditionRepositoryImpl(ExpeditionRemoteDataSourceImpl()));
      final negotiation = await createNegociationUseCase(
        body: event.body,
        customerToken: event.customerToken,
      );
      emit(NegociationCreated(negotiation));
    } catch (e) {
      emit(ExpeditionError(e.toString()));
    }
  }

  List<PackageModel> packages = [PackageModel()];

  Future<void> _onAddPackage(AddPackageEvent event, Emitter<ExpeditionState> emit) async {
    try {
      if (packages.length < 20) {
        packages.add(PackageModel());
      }
      emit(PackagesUpdatedState(
        packagesCount: packages.length,
        packages: List.from(packages),
      ));
    } catch(e){
      emit(ExpeditionError(e.toString()));
    }
  }

  Future<void> _onRemovePackage(RemovePackageEvent event, Emitter<ExpeditionState> emit) async {
    try {
      if (packages.isNotEmpty) {
        packages.removeLast();
      }
      emit(PackagesUpdatedState(
        packagesCount: packages.length,
        packages: List.from(packages),
      ));
    } catch(e){
      emit(ExpeditionError(e.toString()));
    }
  }
  Future<void> _onExpand(ExpandPackageWidgetAction event, Emitter<ExpeditionState> emit)async {
    try{
      emit(ExpandPackageWidgetState(expanded: event.expanded, index: event.index));
    }catch(e){
      emit(ExpeditionError(e.toString()));
    }
  }

  Future<void> _onAddPhoto(
      AddPhotoEvent event,
      Emitter<ExpeditionState> emit,
      ) async {
        debugPrint("packageIndex: ${event.packageIndex}");
        debugPrint("packageIndex: ${event.photoIndex}");
        final current = packages[event.packageIndex];
        if (current.images == null) {
          current.images = [null,null,null];
        }
        UploadExpeditionImage uploadExpeditionImage = UploadExpeditionImage(repo: ExpeditionRepositoryImpl(ExpeditionRemoteDataSourceImpl()));
      String url =  await uploadExpeditionImage.call(imagePath: event.file.path);
       if(url!=null){
         current.images![event.photoIndex] = url;
         emit(PackagesUpdatedState(
             index: event.packageIndex,
             packages: List.from(packages), packagesCount: packages.length));
       }
  }
  Future<void> _onChangeRecipientAddress(
      ChangeRecipientAddressEvent event,
      Emitter<ExpeditionState> emit,
      ) async {
    try {
      if (event.packageIndex < packages.length) {
        packages[event.packageIndex] =
            packages[event.packageIndex].copyWith(adresseDestination: event.address.location);
            packages[event.packageIndex].copyWith(recipientAddress: event.address);
        emit(PackagesUpdatedState(
            index: event.packageIndex,
            packages: List.from(packages), packagesCount: packages.length));
      }
    } catch (e) {
      emit(ExpeditionError(e.toString()));
    }
  }
  Future<void> _onChangeDescription(
      ChangeDescriptionEvent event,
      Emitter<ExpeditionState> emit,
      ) async {
    try {
      if (event.packageIndex < packages.length) {
        packages[event.packageIndex] =
            packages[event.packageIndex].copyWith(description: event.description);
        emit(PackagesUpdatedState(
            index: event.packageIndex,
            packages: List.from(packages), packagesCount: packages.length));
      }
    } catch (e) {
      emit(ExpeditionError(e.toString()));
    }
  }
  Future<void> _onChangeWeight(
      ChangeWeightEvent event,
      Emitter<ExpeditionState> emit,
      ) async {
    try {
      if (event.packageIndex < packages.length) {
        packages[event.packageIndex] =
            packages[event.packageIndex].copyWith(poids: event.weight);
        emit(PackagesUpdatedState(
            index: event.packageIndex,
            packages: List.from(packages), packagesCount: packages.length));


      }
    } catch (e) {
      emit(ExpeditionError(e.toString()));
    }
  }
  Future<void> _onChooseArrivalTown(
      ChooseArrivalTownEvent event,
      Emitter<ExpeditionState> emit,
      ) async {
    try {
      if (event.packageIndex < packages.length) {
        packages[event.packageIndex] =
            packages[event.packageIndex].copyWith(arrivalTown: event.town);
        packages[event.packageIndex] =
            packages[event.packageIndex].copyWith(ligneId: event.lineId);
        emit(PackagesUpdatedState(
            index: event.packageIndex,
            packages: List.from(packages), packagesCount: packages.length));
      }
    } catch (e) {
      emit(ExpeditionError(e.toString()));
    }
  }
  Future<void> _onChooseDepartureTown(
      ChooseDepartureTownEvent event,
      Emitter<ExpeditionState> emit,
      ) async {
    try {
      if (event.packageIndex < packages.length) {
        packages[event.packageIndex] =
            packages[event.packageIndex].copyWith(departureTown: event.town);
        packages[event.packageIndex] =
            packages[event.packageIndex].copyWith(ligneId: event.lineId);
        emit(PackagesUpdatedState(
            index: event.packageIndex,
            packages: List.from(packages), packagesCount: packages.length));
      }
    } catch (e) {
      emit(ExpeditionError(e.toString()));
    }
  }
  Future<void> _onExpeditionInitial(
      ExpeditionInitialEvent event,
      Emitter<ExpeditionState> emit,
      )async{
        packages = [
          PackageModel()
        ];
        emit(ExpeditionInitial());
      }
  Future<void> _onSetPackageCount(
      SetPackageCountEvent event,
      Emitter<ExpeditionState> emit,
      )async {
    if (event.count < packages.length) {
      packages = packages.sublist(0, event.count);
    } else {
      for (int i = packages.length; i < event.count; i++) {
        packages.add(PackageModel());
      }
    }
    if (packages.length > 20) {
      packages = packages.sublist(0, 20);
    }
    emit(PackagesUpdatedState(
      packagesCount: packages.length,
      packages: List.from(packages),
    ));
      }
    Future<void> _onChangeRecipientStringAddress(
        ChangeRecipientStringAddressEvent event,
        Emitter<ExpeditionState> emit,

        )async{
      try {
        if (event.packageIndex < packages.length) {
          packages[event.packageIndex] =
           packages[event.packageIndex].copyWith(adresseDestination: event.address);
          emit(PackagesUpdatedState(
              index: event.packageIndex,
              packages: List.from(packages), packagesCount: packages.length));
        }
      } catch (e) {
        emit(ExpeditionError(e.toString()));
      }
    }
  List<LineModel> linesList = [];
  Future<void> _onGetAvailableLines(
      getAvailableLines event,
      Emitter<ExpeditionState> emit,
      ) async {
    GetShippingLines lines = GetShippingLines(ExpeditionRepositoryImpl(ExpeditionRemoteDataSourceImpl()));
    CustomerModel customerModel = await CustomerUtils.getCustomer();
    linesList = await lines.call(customerToken: customerModel.token!);
  }
  void _chooseShippingMethod(
      chooseShippingMethod event,
      Emitter<ExpeditionState> emit,
      ){
    emit(chooseShippingMethodState(method: event.method));
  }
  Future<void> _chooseShippingMethodAddressType(
      chooseShippingMethodAddressType event,
      Emitter<ExpeditionState> emit,)async{
    if(event.method=="POSITION"){
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String coords = "${position.latitude}:${position.longitude}";
      emit(chooseShippingMethodAddressTypeState(method: event.method,coords: coords));
    }else{
      emit(chooseShippingMethodAddressTypeState(method: event.method,coords: event.coords));
    }

  }
  void _chooseFetchDate(
      chooseFetchDateEvent event,
      Emitter<ExpeditionState> emit,
      ) {
    emit(chooseFetchDateState(date: event.date));
  }
  void _chooseFetchTime(
      chooseFetchTimeEvent event,
      Emitter<ExpeditionState> emit,
      ) {
    emit(chooseFetchTimeState(hour: event.hour));
  }
  void _enterRecipientPhoneNumber(
      enterRecipientPhoneNumber event,
      Emitter<ExpeditionState> emit,
      ) {
    packages[event.packageIndex] =  packages[event.packageIndex].copyWith(recipientPhoneNumber: event.phoneNumber);
    emit(PackagesUpdatedState(
        index: event.packageIndex,packages: packages, packagesCount: packages.length));
  }
  void _enterSendPhoneNumber(
      enterSendPhoneNumber event,
      Emitter<ExpeditionState> emit,
      ) {
    emit(enterSendPhoneNumberState(phoneNumber: event.phoneNumber));
  }
  void _chooseStar(
      chooseStarEvent event,
      Emitter<ExpeditionState> emit,
      ) {
    emit(chooseStarState(star: event.star));
  }
  void _chooseLikable(
      chooseLikableItem event,
      Emitter<ExpeditionState> emit,
      ) {
    emit(chooseLikableState(index: event.index));
  }
}
