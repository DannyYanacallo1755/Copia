
import 'dart:developer';

import '../../../../ui/pages/pages.dart';

part 'company_event.dart';
part 'company_state.dart';


final Map<String, dynamic> filteredParamenters = {
  "uuids": [],
  "searchFields": [],
  "sortOrders": [],
  "page": 1,
  "pageSize": 10,
  "searchString": ""
};

void resetFilteredParameters() {
  filteredParamenters['uuids'] = [];
  filteredParamenters['searchFields'] = [];
  filteredParamenters['sortOrders'] = [];
  filteredParamenters['page'] = 0;
  filteredParamenters['pageSize'] = 10;
  filteredParamenters['searchString'] = "";
}

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final CompanyService _companyService;
  final SocialMediaService _socialMediaService;
  CompanyBloc(CompanyService companyService, SocialMediaService socialmediaService) 
  : _companyService = companyService,
    _socialMediaService = socialmediaService,
  super(const CompanyState()) {
    on<AddCompaniesEvent>((event, emit) => emit(state.copyWith(companies: event.companies)));
    on<AddCompanyStatusEvent>((event, emit) => emit(state.copyWith(status: event.companyStatus)));
    on<AddUserCompanyEvent>((event, emit) => emit(state.copyWith(userCompany: event.userCompany)));
    on<AddSelectedCompanyFormEvent>((event, emit) => emit(state.copyWith(selectedMyCompanyFormIndex: event.index)));
    on<AddCompanyLogoStatusEvent>((event, emit) => emit(state.copyWith(logoStatus: event.logoStatus)));
    on<AddSelctedLogoPathEvent>((event, emit) => emit(state.copyWith(selectedLogoPath: event.path)));
    on<CompanyByIdEvent>((event, emit) async {

      try {
        emit(state.copyWith(status: CompanyStateStatus.loading, banks: []));
        log('comaany id: ${event.companyId}');
        // filteredParamenters['uuids'].add({"fieldName":"company.id", "value":event.companyId});
        filteredParamenters['uuids'].add({"fieldName":"country.id", "value":event.countryId});
        // to fetch 100 banks per request
        filteredParamenters['page'] = 1;
        filteredParamenters['pageSize'] = 100;
        final dynamic company = await _companyService.getCompanyById(event.companyId);
        final dynamic socialMedias = await _socialMediaService.getSocialMedias();
        final dynamic banks = await _companyService.getBanksByCountry(filteredParamenters);
        if (company is Company) {
          add(AddUserCompanyEvent(company));
        }
        if (socialMedias is List<SocialMedia>) {
          emit(state.copyWith(socialMedias: socialMedias));
        }
        if (banks is FilteredData<FilteredBanks>){
          log('company banks: ${banks.content}');
          emit(state.copyWith(banks: banks.content));
        }
        emit(state.copyWith(status: CompanyStateStatus.loaded));
      } catch (e) {
        log('error -> CompanyByIdEvent: $e');
        emit(state.copyWith(status: CompanyStateStatus.error));
      }
    });
    on<UpdateCompanyInformationEvent>((event, emit) async {
      try {
        emit(state.copyWith(status: CompanyStateStatus.updating));
        final dynamic response = await _companyService.updateCompanyInformation(event.companyId, event.uppdatedInfo);
        if (response is Company) {
          SuccessToast(
            title: locator<AppLocalizations>().company_information,
            style: ToastificationStyle.flatColored,
            foregroundColor: Colors.white,
            backgroundColor: Colors.green.shade500,
          ).showToast(AppRoutes.globalContext!);
        }
        emit(state.copyWith(status: CompanyStateStatus.updated));
      } catch (e) {
        log('error: $e');
      }
    });
  }

  Future<void> getCompanies() async {
    final dynamic companies = await _companyService.getCompanies();
    if (companies is List<Company>) {
      add(AddCompaniesEvent(companies));
    }
  }

  Future<void> chooseCompanyLogo() async {
    try {
      add(const AddCompanyLogoStatusEvent(CompanyLogoStatus.loading));
      final ImagePicker picker = locator<ImagePicker>();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        add(AddSelctedLogoPathEvent(image.path));
        await _companyService.uploadCompnayLogo(File(image.path));
      }
      add(const AddCompanyLogoStatusEvent(CompanyLogoStatus.loaded));
    } catch (e) {
      log('Something went wrong while choosing company logo :$e');
      add(const AddCompanyLogoStatusEvent(CompanyLogoStatus.error));
    }
  }

  void addSelectedCompanyForm(int index) =>  add(AddSelectedCompanyFormEvent(index));
}
