# retSim

> From the classical drifting bar stimuli used in population receptive field (pRF) modeling, to empirically-informed estimates of neuronal drive, to retinotopically organized BOLD waves. 



The appeal to evidence that fMRI images provide is enticing and -understandably- lures our intuition into a sense of certainty that, even though sometimes a little vague, can further our scientific understanding of brain structure and function. However, to realize this potential, a question remains: How can we narrow our focus on neuronal activity if fMRI responses at different recording sites can be correlated due to neuroanatomical connections, or metabolic and hemodynamic relationships?  

In a recent study titled "Hemodynamic Traveling Waves in Human Visual Cortex" **[1]** , the authors set out to chart BOLD waves as they spread across the human visual cortex. Further research by the same team described the complex spatiotemporal organization of these cortical responses using a novel spatio-temporal hemodynamic response function **[2]**.




The goal of this repo is two-fold: 

* As a wrapper for [stimBOLD](https://github.com/KevinAquino/stimBOLD), it aims to make the implementation of the st-HRF accessible and transparent. 
  
* As a stepping-stone for fMRI-based retinotopic mapping studies, it aims to provide a malleable sandbox dataset to be used as a benchmark for studies focusing on the fine grained functional neuroanatomy of the early visual cortex in humans. 

## Outline

1. Retinal processing using retinal template (input: image, output: blurred image).
2. Estimation of retinal contrast response function based on luminance (input: blurred image, output: retinal response).
3. Mapping from the retina to V1 (input: retinal response, output: retinal outputs). 
4. Estimation of neural response in V2 and V3 (input: retinal outputs, output: neural activity, neural inputs).
5. Calculation of neural drive (input: neural activity, neural inputs, output: input of hemodynamic model).
6. Hemodynamic model (st-HRF, output: spatio-temporal BOLD) **[3]**.
7. Projection to cortical surface reconstruction mesh.
8. Projection to model of the foveal confluence **[4]**.


## Getting started


First, you need Freesurfer in the path. Then you can source it:
  
```console
export FREESURFER_HOME=/home/.../freesurfer-linux-ubuntu22_amd64-7.4.0/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
```
  
Second, start Matlab:
  
```console
'/home/../Matlab/bin/matlab'
```

Third, you need to copy the barMap folder (the input stimuli *barMap_whole.avi* must be computed previously using *barMap/inputMaker.m*) within retSim into the folder used by stimBOLD to compute the stimulus-to-BOLD respones in V1, V2 and V3, in terminal:

```console
cp -r barMap stimBOLD-master/visualStimuli
```

Fourth, open the script *stimBOLD_wrapper.m* in Matlab and run until line 42. The last line will give you the number of frames in the *barMap_whole.avi* file. A few more frames have been included after all the bar sweeps, to illustrate the residual waves still unfolding after the stimulus have faded out, and as potentially baseline. 

From here onwards, you can go ahead running the scripts in chunks. For instance, first compute the visual inputs (blurring the image according to fixation, lines 68 to 77). Lines 86 to 93 are to load the retinal template and compute the retinal contrast response. Line 102 computes the cortical projection from retina to lateral geniculate nucleus (LGN) to V1. Line 110 computes the neural response in V1 and its retinotopic outputs to V2 and V3. Line 127 calculate the neural drive in V1, V2 and V3. These four steps take relatively little time. Line 136 implements the st-HRF in order to simulate the BOLD response. This last step takes a long long time! This last step results in the file *stimBOLD_bold.mat*, which contains the st-HRF derived BOLD time series simulation (this is a large file and has not been included in the repo. It must be recomputed in order to run some scripts).

The synthesized BOLD time series can then be projected onto the *banded-DoubleSech* model of the foveal confluence **[5]** using the *barMap2bold_grid.m* script. This scripts uses the previously created file *stimBOLD_bold.mat* as input and matches it to the *banded-DoubleSech*. For a detailed account of the model see [here](https://github.com/nicogravel/retSim/blob/main/tools/fovealConf/DemoSchiraEtal2009.m)

> Examples:


|<img src="https://github.com/nicogravel/retSim/blob/main/figures/barMap.png" width=50%>|
|:--:|
| **Input for BOLD simulation.** Drifting bar (original resolution from mrVista parameter files was 768 x 768) was downsampled to 64 x 64 pixels. [Cick here for video](https://drive.google.com/file/d/14MRGpbjya8KwtLup8kAvR8EmKF5svNSr/view?usp=sharing).|



|<img src="https://github.com/nicogravel/retSim/blob/main/figures/stHRF_BOLD_sim_cortex.png" width=70%>|
|:--:|
| **Cortical BOLD response.** Flattened cortical reconstruction showing  cortical hemodynamic responses to the drifting bar stimuli commonly used in pRF mapping (depicted on a flattened cortical reconstruction using the Freesurfer's *fsaverage*  template) and visual cortical maps V1, V2 and V3 (black outlines). Within each of these maps, nearby neurons respond to nearby locations in the visual image, with this property (receptive fields) extending along cortical hierarchy. Neuronal responses across cortical sites were approximated using a mean field approximation of retino-cortical inputs, resulting on stimuli-dependent estimates for the neuronal drive in V1, V2 and V3. These estimates are then translated to BOLD activity using an empirically established spatiotemporal hemodynamic response function (st-HRF). [Click here for video](https://drive.google.com/file/d/17JkrsSYfcZkWn2gZsGGb1wURvY_gLqTL/view?usp=sharing).|


|<img src="https://github.com/nicogravel/retSim/blob/main/figures/retMaps_bandedDoubleSech.png" width=100%>|
|:--:|
| **V1, V2 and V3 sites cluster around the foveal confluence.**  For V1, V2 and V3, left and right halves of the visual field project to opposite cortical hemispheres, with visual field selectivity inverted across the horizontal meridian. Furthermore, V2 and V3 are split into dorsal and ventral quarterfields, each containing an inverted representation of the upper and lower visual field. The organization of early visual cortical maps V1, V2 and V3 cluster around a single foveal representation can be described using an banded 2D model that accounts for retinotopy, cortical magnification and anisotropy.|


|<img src="https://github.com/nicogravel/retSim/blob/main/figures/tSeries_bandedDoubleSech.png" width=100%>|
|:--:|
| **Simulated BOLD time series obtained using the st-HRF.**|


|<img src="https://github.com/nicogravel/retSim/blob/main/figures/stHRF_BOLD_sim_bandedDoubleSech.png" width=85%>|
|:--:|
| **Simulated BOLD time series projected onto the banded-DoubleSech model of the V1-V2-V3 foveal confluence.** Hemodynamic wave-like responses to the drifting bar stimuli unfold across the V1-V2-V3 hierarchy by following inter-areal homotopy. [Cick here for video](https://drive.google.com/file/d/13tFxnNaqPVHgYauDXN5xiREETby12mkx/view?usp=sharing).|

|<img src="https://github.com/nicogravel/retSim/blob/main/figures/interpEcc_bandedDoubleSech.png" width=50%><img src="https://github.com/nicogravel/retSim/blob/main/figures/interpPol_bandedDoubleSech.png" width=50%>|
|:--:|
| **Cortex-to-model mapping of simulated BOLD results in a little sketchiness.** The quality of this mapping depends on the distance functions for the K-nearest neighbors search and the resolution of the model.|




## References

1. Aquino KM, Schira MM, Robinson PA, Drysdale PM, Breakspear M, (2012) [**Hemodynamic Traveling Waves in Human Visual Cortex**](https://doi.org/10.1371/journal.pcbi.1002435). PLOS Computational Biology 8(3): e1002435. 

2. K.M. Aquino, P.A. Robinson, P.M. Drysdale, (2014) [**Spatiotemporal hemodynamic response functions derived from physiology**](https://doi.org/10.1016/j.jtbi.2013.12.027), Journal of Theoretical Biology, 347.118-136. 

3. J.C. Pang, K.M. Aquino, P.A. Robinson, T.C. Lacy, M.M. Schira, (2018) [**Biophysically based method to deconvolve spatiotemporal neurovascular signals from fMRI data**](https://doi.org/10.1016/j.jneumeth.2018.07.009) , Journal of Neuroscience Methods, 308.6-20. 

4. Mark M. Schira, Christopher W. Tyler, Michael Breakspear, Branka Spehar, (2009) [**The Foveal Confluence in Human Visual Cortex**](https://doi.org/10.1523/JNEUROSCI.1760-09.2009). Journal of Neuroscience, 29 (28) 9050-9058; 

5. M. Schira, Mark; W. Tyler, Christopher; Spehar, Branka; Breakspear, Michael, (2015) [**Protocol S1 - Modeling Magnification and Anisotropy in the Primate Foveal Confluence**](https://doi.org/10.1371/journal.pcbi.1000651.s001). PLOS Computational Biology.


