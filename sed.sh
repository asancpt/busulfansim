cd $1
grep -rl 'Caffeine' $1/$2 | xargs sed -i 's/Caffeine/Busulfan/g'
grep -rl 'caffeine' $1/$2 | xargs sed -i 's/caffeine/busulfan/g'
grep -rl 'caff' $1/$2 | xargs sed -i 's/caff/bsfn/g'
grep -rl 'Caff' $1/$2 | xargs sed -i 's/Caff/Bsfn/g'
cd ..

