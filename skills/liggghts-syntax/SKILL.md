---
name: liggghts-syntax
description: >
  LIGGGHTS v3.X input script syntax reference. Covers parsing rules, command reference,
  contact model syntax, variable system, units, particle insertion, mesh/wall setup,
  and output configuration. Trigger: "LIGGGHTS syntax", "LIGGGHTS script", "liggghts command",
  "granular script", "DEM script syntax", "how to write LIGGGHTS input".
---

# LIGGGHTS v3.8.0 Input Script Syntax Reference

Complete reference for writing LIGGGHTS-PUBLIC v3.X input scripts. Based on the official
documentation from the LIGGGHTS-PUBLIC repository.

## 1. Parsing Rules

How LIGGGHTS parses each line of an input script:

1. **Line continuation**: `&` at end of line (outside quotes) joins next line.
   ```
   fix ins all insert/pack seed 123457 distributiontemplate pdd1 &
        insert_every once overlapcheck yes all_in yes
   ```

2. **Comments**: `#` to end-of-line is discarded (except inside quotes).

3. **Variable substitution**: `$x` (single char) or `${myVar}` (multi-char) replaced by variable value.
   Cannot nest: `${b${a}}` is invalid.

4. **Immediate variables**: `$(formula)` evaluates equal-style formula inline.
   ```
   region 1 block $((xlo+xhi)/2+sqrt(v_area)) 2 INF INF EDGE EDGE
   ```

5. **Tokenization**: Line split by whitespace. First token = command name (lowercase). Rest = arguments.

6. **Quoting**: Double or single quotes group text with spaces as one argument. `#` and `$` inside quotes are literal.
   ```
   print "Volume = $v"
   if "${steps} > 1000" then quit
   ```

7. **Command order matters**: Commands execute immediately when read. Order constraints:
   - Initialization commands before atom creation
   - `processors` before `read_data`
   - `pair_style` before `pair_coeff`
   - `fix` commands may depend on previously defined groups/regions

## 2. Input Script Structure

Four required parts (Settings and Run can repeat):

### Part 1: Initialization

```
units         si              # Unit system (required early)
dimension     3               # 2 or 3
newton        off             # Newton's 3rd law: on/off for granular
boundary      m m m           # p=periodic, f=fixed, m=non-periodic shrink-wrap
atom_style    granular        # granular, sphere, superquadric, sph
atom_modify   map array       # global atom mapping
communicate   single vel yes  # ghost communication settings
neighbor      0.002 bin       # neighbor list skin distance and style
neigh_modify  delay 0         # neighbor list rebuild settings
```

### Part 2: Atom/Particle Definition

Three methods:
- **Read file**: `read_data`, `read_restart`
- **Create on lattice**: `lattice` + `region` + `create_box` + `create_atoms`
- **Insert particles** (most common for DEM): `fix insert/pack`, `fix insert/stream`, `fix insert/rate/region`

Particle insertion workflow:
```
# Define material properties
fix m1 all property/global youngsModulus peratomtype 5.e6
fix m2 all property/global poissonsRatio peratomtype 0.45
fix m3 all property/global coefficientRestitution peratomtypepair 1 0.95
fix m4 all property/global coefficientFriction peratomtypepair 1 0.05

# Define particle templates
fix pts1 all particletemplate/sphere 12345787 1 &
    density constant 2500 radius constant 0.0025

# Define particle distribution from templates
fix pdd1 all particledistribution/discrete 17903 1 pts1 1.0

# Insert particles
fix ins all insert/pack seed 123457 distributiontemplate pdd1 &
    vel constant 0. 0. -0.5 insert_every once overlapcheck yes &
    all_in yes particles_in_region 1800 region bc

# Integration fix (required after insertion)
fix integr all nve/sphere
```

### Part 3: Settings

Contact models, material properties, fixes, computes, output.

### Part 4: Run

```
run 10000
# Change settings...
run 20000
```

## 3. Complete Command Reference

### General Commands

| Command | Syntax / Example |
|---------|-----------------|
| `units` | `units style` — style: `si`, `cgs`, `lj`, `real`, `metal`, `micro`, `nano`, `electron` |
| `dimension` | `dimension N` — N = 2 or 3 |
| `newton` | `newton on\|off` — typically `off` for granular |
| `boundary` | `boundary x y z` — `p` periodic, `f` fixed, `m` non-periodic shrink-wrap |
| `atom_style` | `atom_style granular\|sphere\|superquadric\|sph\|...` — must match particle type |
| `atom_modify` | `atom_modify map array` — enables global atom ID mapping |
| `communicate` | `communicate single vel yes` — required for granular pair styles |
| `neighbor` | `neighbor skin style` — e.g. `neighbor 0.002 bin` |
| `neigh_modify` | `neigh_modify delay 0 every 1 check yes` |
| `timestep` | `timestep 1e-5` — time step in current units |
| `processors` | `processors Px Py Pz` — 3d processor grid |
| `run` | `run N [start S1] [stop S2] [every "E c_myCompute"]` |
| `run_style` | `run_style verlet` |
| `reset_timestep` | `reset_timestep N` |
| `include` | `include filename` — include another script file |
| `jump` | `jump file label` — jump to label in file |
| `label` | `label name` — define jump target |
| `next` | `next variable` — advance loop/index variable |
| `if` | `if "condition" then cmd` — conditional execution |
| `print` | `print "text $var"` — print to screen and log |
| `variable` | `variable name style args` — define variable (see Variable System below) |
| `shell` | `shell command` — execute shell command |
| `quit` | `quit` — exit LIGGGHTS |
| `clear` | `clear` — reset all settings |
| `echo` | `echo style` — `none`, `screen`, `log`, `both` |
| `info` | `info args` — system info |
| `log` | `log filename` — specify log file |
| `partition` | `partition yes N` — multi-partition run |
| `write_data` | `write_data file` — write data file |
| `write_restart` | `write_restart file` — write binary restart |
| `write_dump` | `write_dump` — write dump at current timestep |
| `read_data` | `read_data file` — read initial data |
| `read_restart` | `read_restart file` — read restart file |
| `read_dump` | `read_dump file N` — read dump at timestep N |

### Region Commands

```
region ID style args [keyword value...]
```
Styles: `block`, `cylinder`, `cone`, `sphere`, `plane`, `prism`, `wedge`, `mesh/tet`, `union`, `intersect`, `delete`

```
region bc cylinder z 0. 0. 0.05 0.00 0.15 units box
region reg block -0.05 0.05 -0.05 0.05 0. 0.15 units box
region half sphere 0 0 0 5 side out
region combined union 4 r1 r2 r3 r4
```

Keywords: `side in|out`, `units lattice|box`, `move v_x v_y v_z`, `rotate v_theta Px Py Pz Rx Ry Rz`

### Particle Template & Insertion Commands

**fix particletemplate/sphere**: Define spherical particle template
```
fix ID group-ID particletemplate/sphere seed Ntype keyword values...
# keywords: density constant|uniform|gaussian|... value(s)
#           radius constant|uniform|gaussian|... value(s)
```

**fix particletemplate/multisphere**: Define multisphere template
```
fix ID group-ID particletemplate/multisphere seed Ntype file filename ...
```

**fix particletemplate/superquadric**: Define superquadric template
```
fix ID group-ID particletemplate/superquadric seed Ntype ...
```

**fix particledistribution/discrete**: Define distribution from templates
```
fix ID group-ID particledistribution/discrete seed Ntemplates templateID weight [templateID2 weight2 ...]
```

**fix insert/pack**: Pack particles tightly
```
fix ID group-ID insert/pack seed N distributiontemplate distID &
    vel constant vx vy vz &
    insert_every once &
    overlapcheck yes &
    all_in yes &
    particles_in_region N region regionID
```

**fix insert/stream**: Stream particles continuously
```
fix ID group-ID insert/stream seed N distributiontemplate distID &
    nparticles N insert_every M overlapcheck yes &
    vel constant vx vy vz
```

**fix insert/rate/region**: Insert at a rate into a region
```
fix ID group-ID insert/rate/region seed N distributiontemplate distID &
    nparticles N insert_every M region regionID
```

### Material Property Commands

**fix property/global**: Define global material properties
```
fix ID group-ID property/global variablename style [stylearg] defaultvalues...
# variablename = youngsModulus, poissonsRatio, coefficientRestitution,
#                coefficientFriction, characteristicVelocity, etc.
# style = scalar | vector | atomtype | matrix | atomtypepair
```

Required properties for granular contact models:
```
fix m1 all property/global youngsModulus peratomtype 5.e6
fix m2 all property/global poissonsRatio peratomtype 0.45
fix m3 all property/global coefficientRestitution peratomtypepair 1 0.95
fix m4 all property/global coefficientFriction peratomtypepair 1 0.05
```

For cohesion models (sjkr/sjkr2), also required:
```
fix m5 all property/global cohesionEnergyDensity peratomtypepair 1 1e5
```

### Pair Style Commands

**pair_style gran**: Particle-particle granular interaction (3.X syntax)
```
pair_style gran model M [tangential T] [cohesion C] [rolling_friction R] [surface S] &
    [model_options...]
```

**pair_coeff**: Assign pair coefficients
```
pair_coeff * *       # all pairs (for granular, properties are global via fixes)
pair_coeff 1 2 ...   # specific type pairs (for hybrid styles)
```

### Wall/Geometry Commands

**fix wall/gran**: Granular wall boundary (3.X syntax)
```
fix ID group-ID wall/gran model M [tangential T] [cohesion C] [rolling_friction R] [surface S] &
    wallstyle wallargs [general_keywords values] [model_keywords values]

# wallstyle primitive:
fix zwalls all wall/gran model hertz tangential history &
    primitive type 1 zplane 0.15

# wallstyle mesh:
fix meshwalls all wall/gran model hertz tangential history &
    mesh n_meshes 2 meshes cad1 cad2
```

Primitive wall types: `xplane pos`, `yplane pos`, `zplane pos`, `xcylinder r c1 c2`, `ycylinder r c1 c2`, `zcylinder r c1 c2`

For style `mesh`, atom_type comes from the `fix mesh/surface` definition.

Wall keywords:
- `shear dim vshear` — moving wall (primitives only)
- `temperature T0` — wall temperature for heat conduction
- `contact_area overlap|constant [val]|projection`
- `store_force yes|no` — store wall force per-particle
- `store_force_contact yes|no` — store per-contact forces
- `store_force_contact_stress yes|no` — store contact forces & points (selected versions only)

**fix mesh/surface**: Define a mesh for use as wall
```
fix ID group-ID mesh/surface file filename keyword values...
# keywords: type N, scale s, move offx offy offz, rotate phix phiy phiz,
#           curvature value, curvature_tolerant value, heal value,
#           velocity vx vy vz, angular_velocity ax ay az,
#           temperature T, wear finnie|...
```

**fix move/mesh**: Move a mesh
```
fix ID group-ID move/mesh mesh meshID keyword values...
# keywords: linear vx vy vz, angular ax ay az, axis angle,
#           rotate_origin ox oy oz, wiggle ...
```

### Integration Fixes (Time Integration)

```
fix ID group-ID nve/sphere              # spherical particles
fix ID group-ID nve                     # point particles
fix ID group-ID nve/asphere             # aspherical particles
fix ID group-ID nve/superquadric        # superquadric particles
fix ID group-ID nve/noforce             # no force update (freeze translation)
fix ID group-ID nve/asphere/noforce     # no force, aspherical
fix ID group-ID nve/limit N             # limit displacement per step
fix ID group-ID nve/line x|y|z          # 1D motion only
```

### Force/Boundary Condition Fixes

```
fix ID group-ID gravity mag vector gx gy gz
fix ID group-ID setforce fx fy fz       # set force components (NULL = ignore)
fix ID group-ID addforce fx fy fz       # add force to particles
fix ID group-ID viscous gamma           # viscous damping
fix ID group-ID freeze                  # freeze particles in place
fix ID group-ID enforce2d               # enforce 2D (z-force=0)
fix ID group-ID drag ...                # drag force
fix ID group-ID buoyancy ...            # buoyancy force
```

### Diagnostic & Output Fixes

```
fix ID group-ID print N "text $var"
fix ID group-ID ave/time Nevery Nrepeat Nfreq args
fix ID group-ID ave/spatial dim Nevery Nrepeat Nfreq args
fix ID group-ID ave/atom Nevery Nrepeat Nfreq args
fix ID group-ID ave/correlate Nevery Nrepeat Nfreq args
fix ID group-ID ave/histo Nevery Nrepeat Nfreq args
fix ID group-ID ave/euler Nevery Nrepeat Nfreq args
```

### Property/Tracer Fixes

```
fix ID group-ID property/atom variablename style restart yes|no comm yes|no rev_comm yes|no defaults...
fix ID group-ID property/atom/tracer ...
fix ID group-ID property/atom/tracer/stream ...
fix ID group-ID property/atom/regiontracer/time ...
```

### Multisphere Fixes

```
fix ID group-ID multisphere ...
fix ID group-ID multisphere/break ...
```

### Bond Fixes

```
bond_style harmonic|hybrid|none
bond_coeff N K r0             # harmonic: K=spring, r0=equilibrium distance
fix ID group-ID bond/break ...
fix ID group-ID bond/create ...
```

### Heat Transfer

```
fix ID group-ID heat/gran/conduction keyword values...
# keywords: contact_area overlap|constant [val]|projection
#           temperature T0
```

### SPH Fixes

```
fix ID group-ID sph/density/continuity ...
fix ID group-ID sph/density/corr ...
fix ID group-ID sph/density/summation ...
fix ID group-ID sph/pressure ...
```

### Other Fixes

```
fix ID group-ID adapt ...
fix ID group-ID couple/cfd ...
fix ID group-ID check/timestep/gran ...
fix ID group-ID box/relax ...
fix ID group-ID deform ...
fix ID group-ID dt/reset ...
fix ID group-ID spring ...
fix ID group-ID spring/self ...
fix ID group-ID spring/rg ...
fix ID group-ID rigid ...
fix ID group-ID rigid/nve ...
fix ID group-ID rigid/nvt ...
fix ID group-ID planeforce ...
fix ID group-ID lineforce ...
fix ID group-ID store/force ...
fix ID group-ID store/state ...
fix ID group-ID wall/reflect ...
fix ID group-ID wall/region ...
fix ID group-ID wall/region/sph ...
fix ID group-ID move ...
fix ID group-ID massflow/mesh ...
fix ID group-ID massflow/mesh/sieve ...
fix ID group-ID momentum ...
fix ID group-ID poems ...
```

### Compute Commands

```
compute ID group-ID style args
# general keyword: update_on_run_end yes|no
```

Common computes:
```
compute rke all erotate/sphere                    # rotational kinetic energy
compute ke all ke                                 # translational kinetic energy
compute pe all pe                                 # potential energy
compute stress all stress/atom                    # per-atom stress
compute contacts all contact/atom                 # per-atom contact count
compute coord all coord/gran                      # granular coordination number
compute pairforce all pair/gran/local             # pair-wise granular forces (local)
compute displace all displace/atom                # per-atom displacement
compute com all com                               # center of mass
compute pressure all pressure                     # system pressure
compute rdf all rdf Nbin                          # radial distribution function
```

### Dump Commands

```
dump ID group-ID style N file args

# Text dump (custom attributes):
dump dmp all custom 800 post/dump*.id type x y z vx vy vz fx fy fz radius

# VTK dump:
dump dmp all custom/vtk 800 post/dump*.vtk id type x y z vx vy vz

# Mesh VTK:
dump meshdump all mesh/vtk 500 mesh*.vtk vel area meshid

# Image:
dump img all image 1000 dump*.jpg ...

# Mesh STL:
dump stl all mesh/stl 300 post/dump*.stl
```

Wildcards in filename: `*` = timestep, `%` = processor ID.

### Dump Custom Attributes

Atom attributes for `dump custom`:
`id`, `type`, `mol`, `mass`, `x`, `y`, `z`, `xs`, `ys`, `zs`, `xu`, `yu`, `zu`,
`vx`, `vy`, `vz`, `fx`, `fy`, `fz`, `radius`, `diameter`,
`omegax`, `omegay`, `omegaz`, `tqx`, `tqy`, `tqz`,
`angmomx`, `angmomy`, `angmomz`, `ix`, `iy`, `iz`,
`c_ID`, `c_ID[N]`, `f_ID`, `f_ID[N]`, `v_name`

### Thermo Commands

```
thermo N               # output thermodynamic info every N steps
thermo_style style args
# style: one | multi | custom

thermo_style custom step atoms ke c_rke vol dt cpu
thermo_modify lost ignore norm no
compute_modify thermo_temp dynamic yes
```

Thermo custom attributes:
`step`, `elapsed`, `elaplong`, `dt`, `time`, `cpu`, `tpcpu`, `spcpu`, `cpuremain`,
`atoms`, `vol`, `lx`, `ly`, `lz`, `xlo`, `xhi`, `ylo`, `yhi`, `zlo`, `zhi`,
`ke`, `erotate`, `pxx`, `pyy`, `pzz`, `pxy`, `pxz`, `pyz`,
`fmax`, `fnorm`, `c_ID`, `c_ID[I]`, `c_ID[I][J]`, `f_ID`, `f_ID[I]`, `f_ID[I][J]`, `v_name`

### Group Commands

```
group ID style args
# style: type, id, region, union, intersect, subtract, delete, ...
group particles type 1
group inner region bc
group combined union grp1 grp2
```

### Set Commands

```
set group-ID keyword values...
# keyword: type N, diameter val, radius val, property/atom ID val, ...
```

### Other Commands

```
box ...
change_box ...
create_atoms N region regionID
create_box N region regionID
delete_atoms group|region|...
delete_bonds ...
displace_atoms group-ID move dx dy dz
lattice style scale ...
mass type value
orient ...
origin ...
replicate nx ny nz
uncompute ID
undump ID
unfix ID
velocity group-ID set vx vy vz
```

## 4. Contact Model Syntax (3.X `model` keyword system)

This is the KEY syntax change from LIGGGHTS 2.X to 3.X.

### Model Selection Syntax

```
model M [tangential T] [cohesion C] [rolling_friction R] [surface S]
```

### Available Models

| Category | Available Styles | Description |
|----------|-----------------|-------------|
| **model (normal)** | `hooke`, `hooke/stiffness`, `hertz`, `hertz/stiffness` | Normal force model. `hertz` is default |
| **tangential** | `no_history`, `history` | Tangential force model. `history` is default for wall/gran, `off` for pair_style |
| **cohesion** | `off`, `sjkr`, `sjkr2` | Cohesive force model. Default: `off` |
| **rolling_friction** | `off`, `cdt`, `epsd`, `epsd2`, `epsd3` | Rolling friction. Default: `off` |
| **surface** | `sphere`, `superquadric`, `multicontact` | Surface representation. Default: `sphere` |

### Model Settings (optional, appended after model selection)

```
tangential_damping [on]|off    # enable/disable tangential damping
absolute_damping on|[off]      # absolute vs. relative damping
viscous on|[off]               # viscous damping component
limit_force on|[off]           # limit tangential force by Coulomb friction
```

### Example: 2.X vs 3.X Syntax

```
# OLD (2.X):
fix zwalls all wall/gran/hertz/history primitive type 1 zplane 0.15
pair_style gran/hertz/history

# NEW (3.X):
fix zwalls all wall/gran model hertz tangential history primitive type 1 zplane 0.15
pair_style gran model hertz tangential history
```

Full examples:
```
# Hertz with history, no cohesion, CDT rolling friction:
pair_style gran model hertz tangential history rolling_friction cdt

# Hooke with no history (linear spring, no tangential):
pair_style gran model hooke tangential no_history

# Hertz with history and SJKR cohesion:
pair_style gran model hertz tangential history cohesion sjkr

# With tangential damping disabled:
pair_style gran model hertz tangential history tangential_damping off
```

### Required Material Properties by Model

**hertz** model requires:
- `youngsModulus` (peratomtype)
- `poissonsRatio` (peratomtype)
- `coefficientRestitution` (peratomtypepair)
- `coefficientFriction` (peratomtypepair)

**hooke** model requires:
- `kn` (peratomtypepair) — normal stiffness
- `kt` (peratomtypepair) — tangential stiffness
- `gamman` (peratomtypepair) — normal damping coefficient
- `gammat` (peratomtypepair) — tangential damping coefficient
- `coefficientFriction` (peratomtypepair)

**hertz/stiffness** or **hooke/stiffness**: Materials defined per-atom-type via additional properties.

**Cohesion (sjkr/sjkr2)** additionally requires:
- `cohesionEnergyDensity` (peratomtypepair)

### 3.X `fix wall/gran` Full Syntax

```
fix ID group-ID wall/gran &
    model M [tangential T] [cohesion C] [rolling_friction R] [surface S] &
    wallstyle wallargs &
    [shear dim vshear] &
    [temperature T0] &
    [contact_area overlap|constant val|projection] &
    [store_force yes|no] &
    [store_force_contact yes|no] &
    [store_force_contact_stress yes|no] &
    [model_keywords model_values...]
```

### 3.X `pair_style gran` Full Syntax

```
pair_style gran &
    model M [tangential T] [cohesion C] [rolling_friction R] [surface S] &
    [model_keywords model_values...]
```

`pair_style bubble` and `pair_style gran_bubble` are aliases for use with `pair_style hybrid`.

## 5. Variable System

```
variable name style args...
```

### Variable Styles

| Style | Description | Example |
|-------|-------------|---------|
| `index` | List of strings, increment with `next` | `variable x index run1 run2 run3` |
| `loop` | Auto-generate integer sequence | `variable x loop 100` (1..100) |
| `world` | One string per processor partition | `variable temp world 300 310 320` |
| `universe` | Shared across partitions | `variable x universe 1 2 3 ...` |
| `uloop` | Auto-generate for universe | `variable x uloop 15 pad` |
| `string` | Single string, redefinable | `variable f string myfile` |
| `getenv` | Environment variable value | `variable home getenv HOME` |
| `file` | Read strings from file | `variable f file values.txt` |
| `atomfile` | Per-atom values from file | `variable a atomfile data.txt` |
| `equal` | Evaluate formula → scalar | `variable T equal temp/3.0` |
| `atom` | Evaluate formula → per-atom vector | `variable ke atom vx*vx+vy*vy+vz*vz` |
| `delete` | Remove variable | `variable x delete` |

### Variable Referencing

- `$x` — single-char variable, immediate substitution
- `${myVar}` — multi-char variable, immediate substitution  
- `$(formula)` — inline equal-style formula
- `v_name` — in commands expecting variable reference (lazy evaluation)
- `v_name[i]` — atom I's value from per-atom vector

### Equal-Style Variable Formula Elements

**Numbers & math**: `0.0, 100, -5.4, 2.8e-4, PI`

**Operators**: `()`, `-x`, `x+y`, `x-y`, `x*y`, `x/y`, `x^y`, `x==y`, `x!=y`, `x<y`, `x<=y`, `x>y`, `x>=y`, `x&&y`, `x||y`, `!x`

**Math functions**: `sqrt(x)`, `exp(x)`, `ln(x)`, `log(x)`, `abs(x)`, `sin(x)`, `cos(x)`, `tan(x)`, `asin(x)`, `acos(x)`, `atan(x)`, `atan2(y,x)`, `random(x,y,z)`, `normal(x,y,z)`, `ceil(x)`, `floor(x)`, `round(x)`, `ramp(x,y)`, `stagger(x,y)`, `logfreq(x,y,z)`, `stride(x,y,z)`, `vdisplace(x,y)`, `swiggle(x,y,z)`, `cwiggle(x,y,z)`

**Group functions**: `count(group)`, `mass(group)`, `xcm(group,dim)`, `vcm(group,dim)`, `fcm(group,dim)`, `bound(group,dir)`, `gyration(group)`, `ke(group)`, `angmom(group,dim)`, `torque(group,dim)`, `inertia(group,dimdim)`, `omega(group,dim)`

**Region functions** (atoms in region AND group): `count(group,region)`, `mass(group,region)`, etc.

**Special functions**: `sum(x)`, `min(x)`, `max(x)`, `ave(x)`, `trap(x)`, `gmask(x)`, `rmask(x)`, `grmask(x,y)`, `next(x)`

**Thermo keywords**: `vol`, `ke`, `pe`, `atoms`, `step`, `dt`, `time`, `lx`, `ly`, `lz`, etc.

**Compute/fix/variable references**: `c_ID`, `c_ID[i]`, `c_ID[i][j]`, `f_ID`, `f_ID[i]`, `f_ID[i][j]`, `v_name`, `v_name[i]`

**Atom values**: `id[i]`, `mass[i]`, `type[i]`, `x[i]`, `y[i]`, `z[i]`, `vx[i]`, `vy[i]`, `vz[i]`, `fx[i]`, `fy[i]`, `fz[i]`, `omegax[i]`, `omegay[i]`, `omegaz[i]`, `tqx[i]`, `tqy[i]`, `tqz[i]`, `r[i]`, `density[i]`

**Atom vectors** (per-atom in atom-style): `id`, `mass`, `type`, `x`, `y`, `z`, `vx`, `vy`, `vz`, `fx`, `fy`, `fz`, `omegax`, `omegay`, `omegaz`, `r`, `density`

### Variable Evaluation: `$var` vs `v_var`

- `$var` / `${var}`: **Immediate** — evaluated at parse time by input script parser
- `v_var`: **Lazy** — evaluated when referenced command evaluates (e.g., during thermo output, dump)

```
variable v equal vol           # formula, not current value
variable v0 equal $v           # forces immediate evaluation → stores current vol
thermo_style custom v_v v_v0   # v_v = current vol, v_v0 = initial vol
```

## 6. Unit Systems

| System | mass | distance | time | energy | force | pressure |
|--------|------|----------|------|--------|-------|----------|
| `si` | kg | m | s | J | N | Pa |
| `cgs` | g | cm | s | erg | dyne | dyne/cm² |
| `lj` | unitless | sigma | tau | epsilon | epsilon/sigma | epsilon/sigma³ |
| `real` | g/mol | Å | fs | Kcal/mol | Kcal/mol-Å | atm |
| `metal` | g/mol | Å | ps | eV | eV/Å | bar |
| `micro` | pg | µm | µs | pg-µm²/µs² | pg-µm/µs² | pg/(µm-µs²) |
| `nano` | ag | nm | ns | ag-nm²/ns² | ag-nm/ns² | ag/(nm-ns²) |

Default timesteps: `si`=1e-8s, `cgs`=1e-8s, `lj`=0.005 tau, `real`=1 fs, `metal`=0.001 ps.

For DEM/granular simulations, `si` or `cgs` is recommended.

## 7. Common Input Script Patterns

### Minimal Granular Simulation

```
# Initialization
units         si
atom_style    granular
atom_modify   map array
boundary      m m m
newton        off
communicate   single vel yes

# Domain
region        reg block -0.1 0.1 -0.1 0.1 0 0.2 units box
create_box    1 reg
neighbor      0.002 bin
neigh_modify  delay 0

# Material properties
fix           m1 all property/global youngsModulus peratomtype 5.e6
fix           m2 all property/global poissonsRatio peratomtype 0.45
fix           m3 all property/global coefficientRestitution peratomtypepair 1 0.95
fix           m4 all property/global coefficientFriction peratomtypepair 1 0.05

# Contact model
pair_style    gran model hertz tangential history
pair_coeff    * *

# Walls
fix           bottom all wall/gran model hertz tangential history &
                  primitive type 1 zplane 0.0
fix           top all wall/gran model hertz tangential history &
                  primitive type 1 zplane 0.2

# Particle template & insertion
fix           pts all particletemplate/sphere 1234 1 &
                  density constant 2500 radius constant 0.0025
fix           pdd all particledistribution/discrete 5678 1 pts 1.0
region        ins_reg cylinder z 0 0 0.05 0.01 0.19 units box
fix           ins all insert/pack seed 123456 distributiontemplate pdd &
                  vel constant 0 0 -0.5 insert_every once &
                  overlapcheck yes all_in yes &
                  particles_in_region 1000 region ins_reg

# Integration
fix           integr all nve/sphere
timestep      1e-5

# Gravity
fix           grav all gravity 9.81 vector 0 0 -1

# Output
compute       rke all erotate/sphere
thermo_style  custom step atoms ke c_rke vol dt
thermo        1000
thermo_modify lost ignore norm no
dump          dmp all custom 1000 post/dump*.liggghts &
                  id type x y z vx vy vz fx fy fz radius omegax omegay omegaz

# Run
run           100000
```

### Loop Over Multiple Runs

```
variable i loop 10
label loop_start
# ... setup using $i in filenames ...
run 10000
next i
jump in.script loop_start
```

### Variable Timestep-Based Dump Frequency

```
variable dumpfreq equal stride(1000,10000,1000)
dump dmp all custom 1000 post/dump*.id type x y z
dump_modify dmp every v_dumpfreq
```

### Multi-Material Setup

```
# Type 1 properties
fix m1 all property/global youngsModulus peratomtype 5.e6 2.e7
fix m2 all property/global poissonsRatio peratomtype 0.45 0.30
# Pair properties (symmetric matrix: 1-1, 1-2, 2-2)
fix m3 all property/global coefficientRestitution peratomtypepair 2 &
    0.95 0.85 0.75
fix m4 all property/global coefficientFriction peratomtypepair 2 &
    0.05 0.10 0.15
```

### Mesh Wall Setup

```
fix cad1 all mesh/surface file mesh1.stl type 1 scale 0.001
fix cad2 all mesh/surface file mesh2.stl type 1 scale 0.001
fix walls all wall/gran model hertz tangential history &
    mesh n_meshes 2 meshes cad1 cad2
```

## 8. Important Restrictions

- `newton off` is typical for granular simulations
- `communicate single vel yes` is REQUIRED for pair_style gran
- `atom_style granular` stores radius, angular velocity, and torque
- Only self-consistent unit systems (`si`, `cgs`, `lj`) work with granular pair styles
- For mesh walls: use `neighbor bin` (not multi)
- For mesh walls: keep insertion region at least `max_radius + skin/2` from walls
- Planar wall dimensions must be non-periodic
- Material properties in `fix property/global` are NOT written to restart files — must re-specify
- Overlap calculation: `overlapcheck yes` is critical for packing insertions
- `atom_modify map array` required for global atom-ID indexing (needed for `id[i]` in variables)

## 9. Script Command Syntax Summary

```
units si                          # Unit system [MUST be first]
dimension 3 | 2                   # Dimensionality
atom_style granular | sphere | ... # Particle type
boundary p|f|m p|f|m p|f|m       # BC in x y z
newton on | off                   # Newton's 3rd law
communicate single vel yes         # Ghost communication
atom_modify map array              # Global atom mapping
neighbor skin bin                  # Neighbor list params
neigh_modify delay 0               # Build every step

region ID style args               # Define geometric region
create_box N region ID             # Create simulation box
create_atoms N region ID           # Create atoms on lattice

pair_style gran model M [tangential T] [cohesion C] [rolling_friction R]
pair_coeff * *                     # (for granular, properties are global)

fix ID grp property/global NAME STYLE DEFAULTS...
fix ID grp particletemplate/sphere seed type radius... density...
fix ID grp particledistribution/discrete seed N ID1 w1 [ID2 w2...]
fix ID grp insert/pack seed N distributiontemplate DIST ...
fix ID grp insert/stream seed N distributiontemplate DIST ...
fix ID grp insert/rate/region seed N distributiontemplate DIST ...

fix ID grp wall/gran model M tangential T wallstyle TYPE|MESH ...
fix ID grp mesh/surface file FNAME type T [scale S] [move dx dy dz]
fix ID grp move/mesh mesh ID [linear vx vy vz] [angular ax ay az]

fix ID grp nve/sphere              # Time integration (spherical)
fix ID grp nve/superquadric        # Time integration (superquadric)
fix ID grp gravity mag gx gy gz

timestep dt
thermo N
thermo_style custom kw1 kw2 ...
thermo_modify lost ignore norm no
dump ID grp style N file attrs...

run N
```

## 10. How to Use This Skill

When helping users with LIGGGHTS input scripts:
1. Verify the script follows the 4-part structure (Initialization → Atoms → Settings → Run)
2. Check that `units`, `atom_style`, `boundary`, `newton`, `communicate` are set before other commands
3. Ensure 3.X `model` keyword syntax is used for `fix wall/gran` and `pair_style gran` (NOT the old 2.X slash syntax)
4. Verify required material properties match the chosen contact model (hertz vs hooke)
5. Confirm `atom_style granular`, `communicate single vel yes`, and `newton off` for granular simulations
6. Check that `fix property/global` commands precede `pair_style gran` and `fix wall/gran`
7. Verify that `particletemplate` → `particledistribution` → `insert` chain is correct
8. Ensure an integration fix (e.g., `nve/sphere`) is applied to the inserted particles
9. Check `dump` and `thermo_style` reference valid compute IDs
10. For mesh walls: confirm `neighbor bin` and non-periodic wall dimensions
