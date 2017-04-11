public extension VK.Api {
    public enum Database: Method {
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
