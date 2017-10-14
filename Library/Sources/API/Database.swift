public extension PrivateVKAPI {
    public enum Database: APIMethod {
        case getChairs(Parameters)
        case getCities(Parameters)
        case getCitiesById(Parameters)
        case getCountries(Parameters)
        case getCountriesById(Parameters)
        case getFaculties(Parameters)
        case getRegions(Parameters)
        case getSchoolClasses(Parameters)
        case getSchools(Parameters)
        case getStreetsById(Parameters)
        case getUniversities(Parameters)
    }
}
