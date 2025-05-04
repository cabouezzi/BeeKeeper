//
//  GeneData.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/27/24.
//

struct GeneData {
    let gene: Gene
    let details: String
    let cost: Resources
}

extension Gene {
    var details: String {
        switch self {
        
        case .enzymesI:
            return "I peeked into the nectar processing pathway. It's slow. Like, molasses-on-a-winter-morning slow. I’ve begun enhancing the enzyme-producing genes. Expect smoother digestion and maybe even faster honey conversion!"
        case .enzymesII:
            return "More enzymes, less mess! The digestion rate has improved significantly. I accidentally dropped a cracker in their storage chamber and it was gone in seconds."
        case .enzymesIII:
            return "These bees are now biochemical wizards. The enzymes are precise, powerful, and maybe slightly aggressive. I think they tried to dissolve a microscope slide. Beautiful work. Slightly alarming."

        case .engineerI:
            return "Architecture breakthrough! They’ve started shaping their combs with more symmetry. Still primitive, but there’s potential. I’ve identified the neural pattern behind their construction instincts—time to tinker!"
        case .engineerII:
            return "Hexagonal perfection! Their hive layout is now significantly more space-efficient. I dropped a marble in and it rolled straight through 12 chambers. That’s either great design or a fluke."
        case .engineerIII:
            return "I have no idea how they’re doing it, but the new hive structure stores everything better—pollen, nectar, even spare wax. It’s like they took a course in spatial logistics. I am humbled."

        case .furI:
            return "I discovered little hairs sprouting on their thoraxes. At first I thought they were just stylish, but no! They trap tiny particles—like pollen! With some gene coaxing, I should be able to develop a thin, functional fuzz."
        case .furII:
            return "More fur! It’s coming in thicker now—almost like a shag rug. I may or may not have sneezed pollen for an hour after handling one. Definitely a step up in collection efficiency, though."

        case .electricChargeI:
            return "I noticed dust sticking to them like socks fresh out of the dryer. Static charge! With minor tweaks, I can enhance their fur’s ability to generate and retain electricity. More charge, more pollen!"
        case .electricChargeII:
            return "They practically hum with charge now. I rubbed one with a balloon and it zapped me. Pollen collection has doubled. I might use one to power a tiny light bulb next."
        case .electricChargeIII:
            return "These bees are now walking Van de Graaff generators. Pollen leaps onto them mid-flight. It’s like magic. Or magnetism. Or… some kind of sticky electricity thing. The science is solid, trust me."

        case .stripesI:
            return "Subtle patterns are forming on their abdomens—gray stripes. It’s a start, but predators still seem unconvinced. I’ll tweak the pigmentation genes. These bees will be fashion-forward and fearsome."
        case .stripesII:
            return "Success! A beautiful burnt-orange pattern now covers the bees. It’s like Halloween meets hazard tape. Predators are pausing more often… and I’m taking more photos than I should."
        case .stripesIII:
            return "Vibrant yellow! Finally, classic aposematism! These stripes practically shout 'Sting incoming!' from 20 meters away. I believe I’ve achieved peak intimidation via pigmentation."

        case .stingerI:
            return "I tried petting one of the early models. Big mistake. They sting once, fall over, and… well, that’s it. I’ve located a gene sequence that might allow stingers to retract. If this works, they’ll defend themselves and live to buzz another day!"
        case .stingerII:
            return "Progress! The stingers no longer fall off! I’ve reinforced the musculature and chitin sheath—don’t ask how many prototypes I had to prod. The next iteration should pack more punch."
        case .stingerIII:
            return "Well, I had to start wearing thicker gloves. These new stingers are formidable. I've strengthened the venom ducts and refined the tip—like giving them teeny little sabers. Let’s just hope they never unionize."

        case .venomI:
            return "Finally isolated the venom genes! The early samples were... bland. I accidentally licked one. Don’t recommend. But with a little nudge, they’re starting to produce something mildly irritating."
        case .venomII:
            return "After a few… mildly unpleasant incidents, I can confirm the venom’s getting stronger. Enzymatic complexity is increasing! I may have overdone it with Bee #47, though. Poor thing melted a grape."

        case .beeBread:
            return "They’ve started mixing pollen and nectar into… something. It smells fermented and vaguely nutritious. Preliminary analysis shows it’s packed with proteins. Bee cuisine is evolving!"

        case .sustainability:
            return "I’ve fine-tuned their metabolic genes—lower output, higher efficiency. They’re using less energy and producing more per flight. I accidentally left one in a sealed jar overnight. It was still buzzing in the morning!"

        case .bioluminescence:
            return "I was closing the lab last night and one of them glowed. I thought I was hallucinating. But no—it’s bio-luminescence! With a little more gene splicing (and maybe a dash of jellyfish DNA), I think I can make them shine on purpose!"

        case .royalJelly:
            return "I’ve witnessed a worker feeding another with a strange, milky substance. I ran 14 tests—it’s royal jelly! A genetic catalyst for queen development. This could lead to… hierarchy!"
        }
    }
}

