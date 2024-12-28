#import "../template.typ": parec, ez_caption

== Light Emission
<light-emission>
#parec[
  The atoms of an object with temperature above absolute zero are moving. In turn, as described by Maxwell's equations, the motion of atomic particles that hold electrical charges causes objects to emit electromagnetic radiation over a range of wavelengths. As we will see shortly, at room temperature most of the emission is at infrared frequencies; objects need to be much warmer to emit meaningful amounts of electromagnetic radiation at visible frequencies.
][
  温度高于绝对零度的物体的原子在运动。根据麦克斯韦方程，带电粒子的运动导致物体在一系列波长范围内发射电磁辐射。正如我们将很快看到的，在室温下，大部分发射是在红外频率；物体需要更高的温度才能在可见频率下发射出有意义的电磁辐射。
]

#parec[
  Many different types of light sources have been invented to convert energy into emitted electromagnetic radiation. An object that emits light is called a #emph[lamp] or an #emph[illuminant];, though we avoid the latter terminology since we generally use "illuminant" to refer to a spectral distribution of emission (@standard-illuminants). A lamp is housed in a #emph[luminaire];, which consists of all the objects that hold and protect the light as well as any objects like reflectors or diffusers that shape the distribution of light.
][
  为了将能量转化为发射的电磁辐射，人们发明了许多不同类型的光源。发光的物体被称为#emph[灯];或#emph[发光体];，但我们避免使用后者术语，因为我们通常用“发光体”来指代发射的光谱分布（@standard-illuminants）。灯被装在#emph[灯具];中，灯具包括所有固定和保护光的物体以及任何用于塑造光分布的物体，如反射器或扩散器。
]

#parec[
  Understanding some of the physical processes involved in emission is helpful for accurately modeling light sources for rendering. A number of corresponding types of lamps are in wide use today:
][
  了解一些与发射相关的物理过程有助于准确地模拟用于渲染的光源。如今，许多相应类型的灯被广泛使用：
]

#parec[
  - Incandescent (tungsten) lamps have a small tungsten filament. The flow of electricity through the filament heats it, which in turn causes it to emit electromagnetic radiation with a distribution of wavelengths that depends on the filament's temperature. A frosted glass enclosure is often present to diffuse the emission over a larger area than just the filament and to absorb some of the wavelengths generated in order to achieve a desired distribution of emission by wavelength. With an incandescent light, much of the emitted power is in the infrared bands, which in turn means that much of the energy consumed by the light is turned into heat rather than light.
][
  - 白炽灯（钨丝灯）有一个小的钨丝。电流通过钨丝使其加热，从而导致其发射电磁辐射，其波长分布取决于钨丝的温度。通常有一个磨砂玻璃外壳，以便将发射扩散到比钨丝更大的区域，并吸收一些产生的波长，以实现所需的波长发射分布。对于白炽灯，大部分发射功率在红外波段，这意味着消耗的能量大部分转化为热而不是光。
]

#parec[
  - Halogen lamps also have a tungsten filament, but the enclosure around them is filled with halogen gas. Over time, part of the filament in an incandescent light evaporates when it is heated; the halogen gas causes this evaporated tungsten to return to the filament, which lengthens the life of the light. Because it returns to the filament, the evaporated tungsten does not adhere to the bulb surface (as it does with regular incandescent bulbs), which also prevents the bulb from darkening.
][
  - 卤素灯也有一个钨丝，但其周围的外壳充满了卤素气体。随着时间的推移，白炽灯中的一部分钨丝在加热时会蒸发；卤素气体使这些蒸发的钨返回到钨丝上，从而延长灯的寿命。由于蒸发的钨返回到钨丝上，它不会附着在灯泡表面（如普通白炽灯泡），这也防止了灯泡变暗。
]

#parec[
  - Gas-discharge lamps pass electrical current through hydrogen, neon, argon, or vaporized metal gas, which causes light to be emitted at
    specific wavelengths that depend on the particular atom in the gas. (Atoms that emit relatively little of their electromagnetic radiation in the not-useful infrared frequencies are selected for the gas.) Because a broader spectrum of wavelengths is generally more visually desirable than wavelengths that the chosen atoms generate directly, a fluorescent coating on the bulb's interior is often used to transform the emitted wavelengths to a broader range. (The fluorescent coating also improves efficiency by converting ultraviolet wavelengths to visible wavelengths.)
][
  - 气体放电灯通过氢气、氖气、氩气或蒸发的金属气体传导电流，从而在特定波长发射光，这取决于气体中的特定原子。（选择那些在无用的红外频率中发射相对较少电磁辐射的原子用于气体。）由于更宽的波长光谱通常比所选原子直接生成的波长更具视觉吸引力，灯泡内部通常使用荧光涂层来将发射的波长转化为更宽的范围。（荧光涂层还通过将紫外波长转化为可见波长来提高效率。）
]

#parec[
  - LED lights are based on electroluminescence: they use materials that emit photons due to electrical current passing through them.
][
  - LED灯基于电致发光：它们使用由于电流通过而发射光子的材料。
]

#parec[
  For all of these sources, the underlying physical process is electrons colliding with atoms, which pushes their outer electrons to a higher energy level. When such an electron returns to a lower energy level, a photon is emitted. There are many other interesting processes that create light, including chemoluminescence (as seen in light sticks) and bioluminescence—a form of chemoluminescence seen in fireflies. Though interesting in their own right, we will not consider their mechanisms further here.
][
  对于所有这些光源，基础的物理过程是电子与原子碰撞，这推动其外层电子到更高的能级。当这样的电子返回到较低的能级时，会发射出一个光子。还有许多其他有趣的产生光的过程，包括化学发光（如在发光棒中看到的）和生物发光——一种在萤火虫中看到的化学发光形式。尽管它们本身很有趣，但我们在此不再进一步考虑它们的机制。
]

#parec[
  #emph[Luminous efficacy] measures how effectively a light source converts power to visible illumination, accounting for the fact that for human observers, emission in non-visible wavelengths is of little value. Interestingly enough, it is the ratio of a photometric quantity (the emitted luminous flux) to a radiometric quantity (either the total power it uses or the total power that it emits over all wavelengths, measured in flux):
][
  #emph[光效];衡量光源将功率转化为可见光的效率，考虑到对于人类观察者而言，在不可见波长的发射几乎没有价值。有趣的是，它是一个光度量（发射的光通量）与一个辐射量（它使用的总功率或它在所有波长上发射的总功率，以通量测量）的比率：
]

$
  frac(integral Phi_e (lambda) V(lambda) d lambda, integral Phi_i (lambda) d lambda),
$

#parec[
  where $V (lambda)$ is the spectral response curve that was introduced in @luminance-and-photometry.
][
  其中 $V (lambda)$ 是在 @luminance-and-photometry 中介绍的光谱响应曲线。
]

#parec[
  Luminous efficacy has units of lumens per watt. If $Phi_i$ is the power consumed by the light source (rather than the emitted power), then luminous efficacy also incorporates a measure of how effectively the light source converts power to electromagnetic radiation. Luminous efficacy can also be defined as a ratio of luminous exitance (the photometric equivalent of radiant exitance) to irradiance at a point on a surface, or as the ratio of exitant luminance to radiance at a point on a surface in a particular direction.
][
  光效的单位是流明每瓦。如果 $Phi_i$ 是光源消耗的功率（而不是发射的功率），那么光效还包括光源将功率转化为电磁辐射的效率。光效也可以定义为在表面某一点的光出射度（辐射出射度的光度学等效物）与辐照度的比率，或者在特定方向上表面某一点的出射亮度与辐射亮度的比率。
]

#parec[
  A typical value of luminous efficacy for an incandescent tungsten lightbulb is around $15 thin upright("lm/W")$. The highest value it can possibly have is 683, for a perfectly efficient light source that emits all of its light at $lambda = 555 thin upright("nm")$, the peak of the $V (lambda)$ function. (While such a light would have high efficacy, it would not necessarily be a pleasant one as far as human observers are concerned.)
][
  白炽钨丝灯泡的典型光效值约为 $15 thin upright("lm/W")$。最高可达683，对于一个完美高效的光源，它在 $lambda = 555 thin upright("nm")$ 发射所有光，这是 $V (lambda)$ 函数的峰值。（虽然这样的光源会有很高的光效，但对于人类观察者来说不一定是令人愉悦的。）
]

=== Blackbody Emitters
<blackbody-emitters>
#parec[
  A #emph[blackbody] is a perfect emitter: it converts power to electromagnetic radiation as efficiently as physically possible. While true blackbodies are not physically realizable, some emitters exhibit near-blackbody behavior. Blackbodies also have a useful closed-form expression for their emission by wavelength as a function of temperature that is useful for modeling non-blackbody emitters.
][
  #emph[黑体];是一个完美的发射器：它以物理上可能的最高效率将功率转化为电磁辐射。虽然真正的黑体在物理上是不可实现的，但一些发射器表现出接近黑体的行为。黑体还具有一个有用的封闭形式表达式，用于根据温度计算其波长发射，这对于建模非黑体发射器很有用。
]

#parec[
  Blackbodies are so-named because they absorb absolutely all incident power, reflecting none of it. Intuitively, the reasons that perfect absorbers are also perfect emitters stem from the fact that absorption is the reverse operation of emission. Thus, if time was reversed, all the perfectly absorbed power would be perfectly efficiently re-emitted.
][
  黑体之所以得名，是因为它们完全吸收所有入射功率，不反射任何功率。直观上，完美吸收体也是完美发射体的原因在于吸收是发射的逆操作。因此，如果时间倒转，所有完美吸收的功率将被完美高效地重新发射。
]

#parec[
  #emph[Planck's law] gives the radiance emitted by a blackbody as a function of wavelength $lambda$ and temperature $T$ measured in kelvins:
][
  #emph[普朗克定律];给出了黑体发射的辐射亮度作为波长 $lambda$ 和温度 $T$ （以开尔文为单位）的函数：
]

$
  L_e (lambda, T) = frac(2 h c^2, lambda^5 (e^(h c \/ lambda k_b T) - 1)),
$ <plancks-law>


#parec[
  where $c$ is the speed of light in the medium ( $299 , 792 , 458 thin upright("m/s")$ in a vacuum), $h$ is Planck's constant, $6.62606957 times 10^(- 34) thin upright("Js")$, and $k_b$ is the Boltzmann constant, $1.3806488 times 10^(- 23) thin upright("J/K")$, where kelvin (K) is the unit of temperature. Blackbody emitters are perfectly diffuse; they emit radiance equally in all directions.
][
  其中 $c$ 是介质中的光速（在真空中为 $299 , 792 , 458 thin upright("m/s")$ ）， $h$ 是普朗克常数， $6.62606957 times 10^(- 34) thin upright("Js")$，而 $k_b$ 是玻尔兹曼常数， $1.3806488 times 10^(- 23) thin upright("J/K")$，开尔文（K）是温度单位。黑体发射器是完美漫射的；它们在所有方向上均匀地发射辐射亮度。
]

#parec[
  @fig:blackbody-plots plots the emitted radiance distributions of a blackbody for a number of temperatures.
][
  @fig:blackbody-plots 绘制了黑体在若干温度下的发射辐射亮度分布。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f12.svg"),
  caption: [ #ez_caption[ Plots of emitted radiance as a function of wavelength for blackbody emitters at a few temperatures, as given by @eqt:plancks-law. Note that as temperature increases, more of the emitted light is in the visible frequencies (roughly `380 nm-780 nm`) and that the spectral distribution shifts from reddish colors to bluish colors. The total amount of emitted energy grows quickly as temperature increases, as described by the Stefan–Boltzmann law in @eqt:stefan-boltzmann.][ 根据@eqt:plancks-law，绘制了黑体发射器在几个温度下的辐射亮度随波长的分布。注意，随着温度的升高，更多的发射光在可见频率（大约`380 nm-780 nm`）范围内，并且光谱分布从红色向蓝色移动。随着温度的升高，发射能量的总量迅速增加，如@eqt:stefan-boltzmann 中的斯特藩-玻尔兹曼定律所述。
    ]
  ],
)<blackbody-plots>


#parec[
  The `Blackbody()` function computes emitted radiance at the given temperature `T` in Kelvin for the given wavelength `lambda`.
][
  `Blackbody()`函数计算给定温度`T`（以开尔文为单位）和给定波长`lambda`下的发射辐射亮度。
]

```cpp
Float Blackbody(Float lambda, Float T) {
    if (T <= 0) return 0;
    const Float c = 299792458.f;
    const Float h = 6.62606957e-34f;
    const Float kb = 1.3806488e-23f;
    // Return emitted radiance for blackbody at wavelength lambda
    Float l = lambda * 1e-9f;
    Float Le = (2 * h * c * c) /
        (Pow<5>(l) * (FastExp((h * c) / (l * kb * T)) - 1));
    return Le;
}
```


#parec[
  The wavelength passed to `Blackbody()` is in nm, but the constants for @eqt:plancks-law are in terms of meters. Therefore, it is necessary to first convert the wavelength to meters by scaling it by $10^(- 9)$.
][
  传递给`Blackbody()`的波长以纳米为单位，但@eqt:plancks-law 的常数以米为单位。因此，首先需要通过缩放 $10^(- 9)$ 将波长转换为米。
]

#parec[
  The emission of non-blackbodies is described by #emph[Kirchhoff's law];, which says that the emitted radiance distribution at any frequency is equal to the emission of a perfect blackbody at that frequency times the fraction of incident radiance at that frequency that is absorbed by the object. (This relationship follows from the object being assumed to be in thermal equilibrium.) The fraction of radiance absorbed is equal to 1 minus the amount reflected, and so the emitted radiance is.
][
  非黑体的发射由#emph[基尔霍夫定律];描述，该定律指出，任何频率下的发射辐射亮度分布等于该频率下完美黑体的发射乘以该频率下物体吸收的入射辐射亮度的分数。（这种关系源于假设物体处于热平衡状态。）吸收的辐射亮度分数等于1减去反射的量，因此发射的辐射亮度为。
]

$ L prime_nu (T , omega , lambda) = L_nu (T , lambda) (1 - rho_(h d) (omega)) , $ <kirchoffs-law>
#parec[
  where $L_nu (T , lambda)$ is the emitted radiance given by Planck's law, @eqt:plancks-law, and $rho_(h d) (omega)$ is the hemispherical-directional reflectance from @eqt:rho-hd.
][
  其中 $L_nu (T , lambda)$ 是由普朗克定律给出的发射辐亮度，@eqt:plancks-law ，而 $rho_(h d) (omega)$ 是@eqt:rho-hd 中的半球-方向反射率。
]

#parec[
  The #emph[Stefan–Boltzmann law] gives the radiant exitance (recall that this is the outgoing irradiance) at a point $p$ for a blackbody emitter:
][
  #emph[斯特藩-玻尔兹曼定律];给出了黑体发射器在点 $p$ 的辐射出射率（回想一下，这是出射辐照度）：
]

$ M (p) = sigma T^4 , $ <stefan-boltzmann>

#parec[
  where $sigma$ is the Stefan–Boltzmann constant, $5.67032 times 10^(- 8) thin upright(W thin m^(- 2) thin K^(- 4))$. Note that the total emission over all frequencies grows very rapidly—at the rate $T^4$. Thus, doubling the temperature of a blackbody emitter increases the total energy emitted by a factor of 16.
][
  其中 $sigma$ 是斯特藩-玻尔兹曼常数， $5.67032 times 10^(- 8) thin upright(W thin m^(- 2) thin K^(- 4))$。注意，所有频率上的总发射量增长得非常快——以 $T^4$ 的速率。因此，将黑体发射器的温度加倍会使总发射能量增加16倍。
]

#parec[
  The blackbody emission distribution provides a useful metric for describing the emission characteristics of non-blackbody emitters through the notion of #emph[color temperature];. If the shape of the emitted spectral distribution of an emitter is similar to the blackbody distribution at some temperature, then we can say that the emitter has the corresponding color temperature. One approach to find color temperature is to take the wavelength where the light's emission is highest and find the corresponding temperature using #emph[Wien's displacement law];, which gives the wavelength where emission of a blackbody is maximum given its temperature:
][
  黑体发射分布通过#emph[色温];的概念为描述非黑体发射器的发射特性提供了一个有用的指标。 如果发射器的光谱分布形状与某一温度下的黑体分布相似，那么我们可以说该发射器具有相应的色温。 找到色温的一种方法是取光的发射最高的波长，并使用#emph[维恩位移定律];找到相应的温度，该定律给出了黑体在给定温度下发射最大值的波长：
]

$ lambda_(m a x) = b / T , $ <wien-displacement>
#parec[
  where $b$ is Wien's displacement constant, $2.8977721 times 10^(- 3) thin upright(m thin K)$.
][
  其中 $b$ 是维恩位移常数， $2.8977721 times 10^(- 3) thin upright(m thin K)$。
]

#parec[
  Incandescent tungsten lamps are generally around 2700 K color temperature, and tungsten halogen lamps are around 3000 K. Fluorescent lights may range all the way from 2700 K to 6500 K. Generally speaking, color temperatures over 5000 K are described as "cool," while 2700–3000 K is described as "warm."
][
  白炽钨灯的色温通常在2700 K左右，钨卤素灯约为3000 K。 荧光灯的色温可能从2700 K到6500 K不等。 一般来说，色温超过5000 K被描述为“冷”，而2700–3000 K被描述为“暖”。
]

=== Standard Illuminants
<standard-illuminants>


#parec[
  Another useful way of categorizing light emission distributions is a number of "standard illuminants" that have been defined by Commission Internationale de l'Éclairage (CIE).
][
  另一种分类光发射分布的有用方法是由国际照明委员会（CIE）定义的若干“标准光源”。
]

#parec[
  The Standard Illuminant A was introduced in 1931 and was intended to represent average incandescent light. It corresponds to a blackbody radiator of about $2856 thin upright(K)$. (It was originally defined as a blackbody at $2850 thin upright(K)$, but the accuracy of the constants used in Planck's law subsequently improved. Therefore, the specification was updated to be in terms of the 1931 constants, so that the illuminant was unchanged.)@fig:a-illuminant shows a plot of the spectral distribution of the A illuminant.
][
  标准光源A于1931年引入，旨在代表平均白炽光。 它相当于约 $2856 thin upright(K)$ 的黑体辐射器。 （最初定义为 $2850 thin upright(K)$ 的黑体，但普朗克定律中使用的常数的精度后来得到了改进。 因此，规范被更新为以1931年的常数为准，以便光源保持不变。）@fig:a-illuminant 显示了A光源的光谱分布图。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f13.svg"),
  caption: [ #ez_caption[Plot of the CIE Standard Illuminant A's Spectral Power Distribution as a Function of Wavelength in nm. This illuminant represents incandescent illumination and is close to a blackbody at .][ CIE标准光源A的光谱功率分布随波长（nm）变化的图示。该光源代表白炽灯照明，其光谱接近于温度为2856K的黑体。
    ]
  ],
)<a-illuminant>
#parec[
  (The B and C illuminants were intended to model daylight at two times of day and were generated with an A illuminant in combination with specific filters. They are no longer used. The E illuminant is defined as having a constant spectral distribution and is used only for comparisons to other illuminants.)
][
  （B和C光源旨在模拟一天中两个时间的日光，并通过与特定滤光片结合的A光源生成。 它们不再使用。E光源被定义为具有恒定光谱分布，仅用于与其他光源的比较。）
]

#parec[
  The D illuminant describes various phases of daylight. It was defined based on characteristic vector analysis of a variety of daylight spectra, which made it possible to express daylight in terms of a linear combination of three terms (one fixed and two weighted), with one weight essentially corresponding to yellow-blue color change due to cloudiness and the other corresponding to pink-green due to water in the atmosphere (from haze, etc.). D65 is roughly $6504 thin upright(K)$ color temperature (not $6500 thin upright(K)$ —again due to changes in the values used for the constants in Planck's law) and is intended to correspond to mid-day sunlight in Europe. (See @fig:d-illuminant.) The CIE recommends that this illuminant be used for daylight unless there is a specific reason not to.
][
  D光源描述了各种日光阶段。 它是基于对各种日光光谱的特征向量分析定义的，这使得可以用三个项（一个固定和两个加权）的线性组合来表达日光， 其中一个权重基本上对应于由于云量变化的黄蓝色变化，另一个对应于由于大气中的水（如雾霾等）导致的粉红绿色变化。 D65大约为 $6504 thin upright(K)$ 色温（不是 $6500 thin upright(K)$ ——同样是由于普朗克定律中使用的常数值的变化）并旨在模拟欧洲正午的阳光。 （见@fig:d-illuminant。）CIE建议，除非有特定原因，否则应使用此光源来代表日光。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f14.svg"),
  caption: [ #ez_caption[Plot of the CIE Standard D65 Illuminant Spectral Distribution as a Function of Wavelength in nm. This illuminant represents noontime daylight at European latitudes and is commonly used to define the whitepoint of color spaces (@rgb-color-spaces).][ CIE标准光源D65的光谱分布随波长（nm）变化的图示。该光源代表欧洲纬度的正午日光，通常用于定义色彩空间的白点（@rgb-color-spaces）。
    ]
  ],
)<d-illuminant>

#parec[
  Finally, the F series of illuminants describes fluorescents; it is based on measurements of a number of actual fluorescent lights.
][
  最后，F系列光源描述了荧光灯；它基于对多种实际荧光灯的测量。
]

#parec[
  @fig:f-illuminant shows the spectral distributions of two of them.
][
  @fig:f-illuminant 显示了其中两个的光谱分布。
]


#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f15.svg", width: 70%),
  caption: [ #ez_caption[ *Plots of the F4 and F9 Standard Illuminants as a Function of Wavelength in nm.* These represent two fluorescent lights. Note that the distributions are quite different. Spikes in the two distributions correspond to the wavelengths directly emitted by atoms in the gas, while the other wavelengths are generated by the bulb's fluorescent coating. The F9 illuminant is a "broadband" emitter that uses multiple phosphors to achieve a more uniform spectral distribution. ][*F4和F9标准光源随波长变化的图。*这些代表了两种荧光灯。注意分布差异很大。 两个分布中的峰值对应于气体中原子直接发射的波长，而其他波长是由灯泡的荧光涂层产生的。 F9光源是一个“宽带”发射器，使用多种磷光体来实现更均匀的光谱分布。 ]
  ],
)<f-illuminant>