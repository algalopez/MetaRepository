/*
root@05ce4c7e6595:/funspel/07-Lenses# java Lenses.java

https://gist.github.com/mathieuancelin/bb30a104c17037e34f0b
https://github.com/remeniuk/java-lenses/blob/master/core/src/main/java/org/scalaby/fjava/Lens.java
*/

import java.util.Arrays;
import java.util.List;
import java.util.function.BiFunction;
import java.util.function.Function;
import java.util.function.UnaryOperator;
import java.util.stream.Collectors;
import java.util.stream.IntStream;


public class Lenses {

    /*
        -----------------------------------------------
        DEEP IMMUTABLE DATA STRUCTURE
        -----------------------------------------------
    */

    public class TvShow {
        public final String name;
        public final List<Season> seasons;
        TvShow(String name, List<Season> seasons) { this.name = name; this.seasons = seasons;}
        public TvShow withName(String newName) { return new TvShow(newName, seasons);}
        public TvShow withSeasons(List<Season> newSeasons) { return new TvShow(name, newSeasons);}
        public TvShow withSeason(Integer index, Season newSeason) { 
            List<Season> newSeasons = IntStream.range(0 , this.seasons.size())
            .mapToObj(i -> index.equals(i) ? newSeason : this.seasons.get(i))
            .collect(Collectors.toList());
            return new TvShow(name, newSeasons);
        }
        @Override public String toString() {  return "TvShow={\"name\":" + name + ", \"seasons\":" + seasons.stream().map(Object::toString).collect(Collectors.joining(",")) + "}"; }
    }

    public class Season {
        public final List<Episode> episodes;
        Season(List<Episode> episodes) {this.episodes = episodes;}
        public Season withEpisodes(List<Episode> newEpisodes) { return new Season(newEpisodes); }
        public Season withEpisode(Integer index, Episode newEpisode) { 
            List<Episode> newEpisodes = IntStream.range(0 , this.episodes.size())
            .mapToObj(i -> index.equals(i) ? newEpisode : this.episodes.get(i))
            .collect(Collectors.toList());
            return new Season(newEpisodes);
        }
        @Override public String toString() { return "["+episodes.stream().map(Object::toString).collect(Collectors.joining(","))+"]"; }
    }

    public class Episode {
        public final Integer number;
        public final String name;
        Episode(Integer number, String name) {this.number = number; this.name = name;}
        public Episode withNumber(Integer newNumber) {return new Episode(newNumber, this.name);}
        public Episode withName(String newName) {return new Episode(this.number, newName);}
        @Override public String toString() { return "{\"number\":"+number+", \"name\":"+name+"}"; }
    }

    /*
        -----------------------------------------------
        LENS
        -----------------------------------------------
    */

    public class Lens<A, B> {

        private final Function<A, B> getter;
        private final BiFunction<A, B, A> setter;
    
        public Lens(Function<A, B> getter, BiFunction<A, B, A> setter) { this.getter = getter; this.setter = setter; }

        public Function<A, A> modify(UnaryOperator<B> mapper) {
            return oldValue -> {
                B extracted = getter.apply(oldValue);
                B transformed = mapper.apply(extracted);
                return setter.apply(oldValue, transformed);
            };
        }
    
        public Function<Function<B, B>, A> modify(A oldValue) {
            return mapper -> {
                B extracted = getter.apply(oldValue);
                B transformed = mapper.apply(extracted);
                return setter.apply(oldValue, transformed);
            };
        }
    
        // Form Lens<A,B> compose Lens<B,C> returns Lens<A,C>
        public <C> Lens<A, C> compose(Lens<B, C> other) {
            return new Lens<>(
                (A a) -> getter.andThen(other.getter).apply(a),
                (A a, C c) -> {
                    B b = getter.apply(a);
                    B newB = other.modify(ignored -> c).apply(b);
                    return setter.apply(a, newB);
                }
            );
        }
    }

    /*
        -----------------------------------------------
        MAIN
        -----------------------------------------------
    */

    class LensApplication {
        
        Lens<TvShow, String> tvShowNameLens = new Lens<>(t -> t.name, TvShow::withName);
        Lens<TvShow, List<Season>> tvShowSeasonsLens = new Lens<>(t -> t.seasons, TvShow::withSeasons);
        Lens<Season, List<Episode>> seasonEpisodesLens = new Lens<>(s -> s.episodes, Season::withEpisodes);
        Lens<Episode, String> episodeNameLens = new Lens<>(s -> s.name, Episode::withName);
        Lens<Episode, Integer> episodeNumberLens = new Lens<>(s -> s.number, Episode::withNumber);

        Lens<TvShow, Season> tvShowSeason0Lens  = new Lens<>(t -> t.seasons.get(0), (tvShow, newSeason) -> tvShow.withSeason(0, newSeason));
        Lens<Season, Episode> seasonEpisode0Lens  = new Lens<>(t -> t.episodes.get(0), (season, newEpisode) -> season.withEpisode(0, newEpisode));


        Lens<TvShow, List<Episode>> tvShowSeason0EpisodesLens = tvShowSeason0Lens.compose(seasonEpisodesLens);
        Lens<TvShow, Episode> tvShowSeason0Episode0Lens = tvShowSeason0Lens.compose(seasonEpisode0Lens);
        Lens<TvShow, String> tvShowSeason0Episode0NameLens = tvShowSeason0Lens.compose(seasonEpisode0Lens).compose(episodeNameLens);
        Lens<TvShow, Integer> tvShowSeason0Episode0NumberLens = tvShowSeason0Lens.compose(seasonEpisode0Lens).compose(episodeNumberLens);
    }

    /*
        -----------------------------------------------
        OBJECT MOTHER
        -----------------------------------------------
    */

    class TvShowDataStub {
        TvShow getCommunityShow() {
            SeasonDataStub seasonDataStub = new SeasonDataStub();
            Season communityS01 = seasonDataStub.getCommunitySeason1();
            Season communityS02 = seasonDataStub.getCommunitySeason2();
            return new TvShow("Community", Arrays.asList(communityS01, communityS02));
        }
    }

    class SeasonDataStub {
        Season getCommunitySeason1() {
            Episode communityS01E01 = new Episode(1, "Pilot");
            Episode communityS01E02 = new Episode(2, "Spanish 101");
            return new Season(Arrays.asList(communityS01E01, communityS01E02));
        }
        Season getCommunitySeason2() {
            Episode communityS02E01 = new Episode(1, "Anthropology 101");
            Episode communityS02E02 = new Episode(2, "Accounting for Lawyers");
            return new Season(Arrays.asList(communityS02E01, communityS02E02));
        }
    }

    /*
        -----------------------------------------------
        MAIN
        -----------------------------------------------
    */

    public static void main(String[] var0) {
        Lenses classWrapper = new Lenses();
        LensApplication lensApplication = classWrapper.new LensApplication();

        TvShow community = classWrapper.new TvShowDataStub().getCommunityShow();

        print("Original tvShow");
        print(community.toString());

        print("Change tvShow name");
        print(lensApplication.tvShowNameLens.modify(String::toUpperCase).apply(community));

        print("Change tvShow -> Season 0 -> episodes ");
        print(lensApplication.tvShowSeason0EpisodesLens.modify(ign -> Arrays.asList(classWrapper.new Episode(2, "Changing all season 0 episodes"))).apply(community));

        print("Change tvShow -> Season 0 -> episode 0");
        print(lensApplication.tvShowSeason0Episode0Lens.modify(ign -> classWrapper.new Episode(2, "New episode")).apply(community));

        print("Change tvShow -> Season 0 -> episode 0 -> name");
        print(lensApplication.tvShowSeason0Episode0NameLens.modify(ign -> "New name for episode").apply(community));

        print("Change tvShow -> Season 0 -> episode 0 -> number");
        print(lensApplication.tvShowSeason0Episode0NumberLens.modify(ign -> 213).apply(community));
    }

    private static void print(Object s) { System.out.println(s); }
}

