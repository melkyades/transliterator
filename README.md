# Transliterator

WIP.

An attempt to provide a set of tools to allow moving code between different dialects.

## Idea in a glimpse

1. Conceptually, the framework just applies a set of transliteration rules to generate code in different dialects.
2. The framework provides generic rules for porting between pairs of dialects.
3. Additionally, a project can manually add more rules specially crafted for particular porting mismatches.
4. A project would have one git repo per dialect.
5. A project should define its main dialect. A CI job should be triggered when committing so that other dialect repos get updated.
6. Potentially, a developer in other than main dialect might commit to its repo, and rules should be (automatically) reversed to allow porting back to the main repo.


## Loading

For now, we only suppor transliterating from Pharo (until we transliterate the transliterator :),
so the code only loads on Pharo.

Transliterator uses Powerlang compiler to parse code and apply the rules. For now, you need to first
load Powerlang to get the compiler (maybe some day we split it into another package).

Then you have to load this repo (todo: add script to load it here).

## Usage

TBD.
