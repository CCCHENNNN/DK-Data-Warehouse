import java.util.regex.*; //Matcher, Pattern public class Regexptest
public class regex{
public static void main(String[] args)
{
System.out.println(Pattern.matches("\\w* mops", "with mops")); //false
System.out.println(Pattern.matches("([a-z ]*)\\a*side", "from side"));
      Pattern p = Pattern.compile("([a-z ]*)\\s*side");
      Matcher m = p.matcher("from side to");
while (m.find( )) {
System.out.println("Line: " + m.group(0)); //"Line: from side" System.out.println("Value: " + m.group(1)); //"Value: from " System.out.println(m.start() + " " + m.end()); //0 9
}
System.out.println(m.matches()); //false: should match entire region
System.out.println(m.replaceAll("z")); //z to
} }