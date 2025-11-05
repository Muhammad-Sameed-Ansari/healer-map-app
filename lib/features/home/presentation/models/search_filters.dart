class SearchFilters {
  final String? search;
  final String? categoryId; // pass as string id
  final String? language; // pass as display name, e.g., 'German'
  final String? distanceKm; // '5','10', etc. (optional)
  final bool barterAgreement;
  final bool nearToMe;
  final int limit;
  final int page;

  const SearchFilters({
    this.search,
    this.categoryId,
    this.language,
    this.distanceKm,
    this.barterAgreement = false,
    this.nearToMe = false,
    this.limit = 10,
    this.page = 1,
  });

  Map<String, dynamic> toQuery() {
    final q = <String, dynamic>{
      'limit': limit,
      'page': page,
    };
    if (search != null && search!.trim().isNotEmpty) q['search'] = search;
    if (categoryId != null && categoryId!.isNotEmpty) q['category'] = categoryId;
    if (language != null && language!.isNotEmpty) q['language'] = language;
    if (barterAgreement) q['barter_agreement'] = 1;
    // Optional extras if backend supports
    if (nearToMe) q['near_to_me'] = 1;
    if (distanceKm != null && distanceKm!.isNotEmpty) q['distance'] = distanceKm;
    return q;
  }
}
