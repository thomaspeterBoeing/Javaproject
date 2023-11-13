public class PolicySearchResponse {
    public List<CMGCommon.ConsumerProfileType> ConsumerProfileList { get; set; }

    public static PolicySearchResponse parse(String json) {
        return (PolicySearchResponse) System.JSON.deserialize(json, PolicySearchResponse.class);
    }
}