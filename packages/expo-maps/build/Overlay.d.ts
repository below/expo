import React from 'react';
import { Point } from './Common.types';
/**
 * Overlay specific props.
 */
export declare type OverlayProps = {
    /**
     * South west, and north east corners of the image.
     */
    bounds: {
        /**
         * South west corner coordinates.
         */
        southWest: Point;
        /**
         * North east corner coordinates.
         */
        northEast: Point;
    };
    /**
     * Custom overlay graphic
     */
    icon: string;
};
export declare type OverlayObject = {
    type: 'overlay';
} & OverlayProps;
/**
 * Ground Overlay component of Expo Maps library.
 *
 * Draws custom ground overlays on ExpoMap.
 * This component should be ExpoMap component child to work properly.
 *
 * See {@link OverlayProps} for more details.
 */
export declare class Overlay extends React.Component<OverlayProps> {
    render(): null;
}
//# sourceMappingURL=Overlay.d.ts.map