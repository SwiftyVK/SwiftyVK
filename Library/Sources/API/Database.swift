public extension PrivateVKAPI {
    public enum Database: APIMethod {
        case getCountries(Parameters)
        case getRegions(Parameters)
        case getStreetsById(Parameters)
        case getCountriesById(Parameters)
        case getCities(Parameters)
        case getCitiesById(Parameters)
        case getUniversities(Parameters)
        case getSchools(Parameters)
        case getSchoolClasses(Parameters)
        case getFaculties(Parameters)
        case getChairs(Parameters)
    }
}
