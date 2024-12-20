# retSim

*From the pRF drifting bar stimuli to neuronal drive to BOLD using a spatio-temporal hemodynamic response function derived from physiology* 

This is wrapper for [stimBOLD](https://github.com/KevinAquino/stimBOLD).


1. Retinal processing using retinal template (input: image, output: blurred image )
2. Estimation of retinal contrast response function based on luminance (input: blurred image, output: retinal response)
3. Mapping from the retina to V1 (input: retinal response, output: retinal outputs) 
4. Estimation of neural response in V2 and V3 (input: retinal outputs, output: neural activity, neural inputs)
5. Calculation of neural drive (input: neural activity, neural inputs, output: input of hemodynamic model)
6. Hemodynamic model (stHRF, output: spatio-temporal BOLD)
7. Projection to cortical surface reconstruction mesh
8. Projection to model of the foveal confluence model


The first part (points 1-5) has been pre-run (file: stimBOLD_neural_20dec2024.mat). The conversion to BOLD using the spatio-temporal HRF takes a long time to run.

> Examples:

|<img src="https://github.com/nicogravel/retSim/blob/main/figures/barMap.png" width=100%>|
|:--:|
| **Input for BOLD simulation.** Drifting bar (original resolution from mrVista parameter files was 768 x 768) was downsampled to 64 x 64 pixels. Output. [Cick here for video](https://drive.google.com/file/d/14MRGpbjya8KwtLup8kAvR8EmKF5svNSr/view?usp=sharing).|



|<img src="https://github.com/nicogravel/retSim/blob/main/figures/bbarMap_cortex.png" width=100%>|
|:--:|
| **Cortical BOLD response.** Hemodynamic responses to drifting bar stimuli depicted on Freesurfer's *fsaverage* cortical surfcace template. Neuronal responses on cortex were approximated using a  mean field model of retino-cortical input resulting on a stimuli-dependent neuronal drive of V1, V2 and V3. The resulting neuronal drive were translated to BOLD activity using a spatiotemporal hemodynamic response function (st-HRF). [Cick here for video](https://drive.google.com/file/d/17JkrsSYfcZkWn2gZsGGb1wURvY_gLqTL/view?usp=sharing).|



|<img src="https://github.com/nicogravel/retSim/blob/main/figures/barMap_Schwartz.png" width=100%>|
|:--:|
| **Cortical BOLD response projected on the Schwartz model of the foveal confluence model.** Hemodynamic responses to drifting bar stimuli depicted on the Schwartz model of the foveal confluence. [Cick here for video](https://drive.google.com/file/d/1uSTpQjf0pSlLYJeW-Iz0umAtCfez18K_/view?usp=sharing).|

