# fossbilling-demo
Way to Hacky. But if you are too lazy to do it manually this should work. Please DO NOT USE it!!!!!! 

## Steps follows

- Takes Exsting Docker containers down
- Deletes Images and Volumes
- Start new Containers from Docker
- Run Installer
- Modify config.php due to bug: #1977
- Clone Demo module and copy it to Container
- Create new Client + Enable Demo
- Create demo.sql for hourly reset
- Update HTML login pages 
- Create Cronjobs

## Why?

Because I can save a few minutes each times. As it will create a new "Install" each release any database structure changes will follow...

## Why not?

- Standaard Username / Password 
- If Client / Demo table Structure changes we might need to make changes 
- This is not designed for a production system(s) 

## Warning!

If you decide to use it don't ask for support! 