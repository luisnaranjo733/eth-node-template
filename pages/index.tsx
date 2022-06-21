import {
  IPivotStyleProps,
  IPivotStyles,
  IStyleFunctionOrObject,
  ITextProps,
  Label,
  Pivot,
  PivotItem,
  PrimaryButton,
  Text,
} from '@fluentui/react';
import Page from '../components/Page';
import Image from 'next/image';
import BYONP_S from '../public/BYONP-S.png';
import BYONP_M from '../public/BYONP-M.png';
import BYONP_L from '../public/BYONP-L.png';
import { useCallback } from 'react';
import styles from '../styles/index.module.scss';

const pivotStyles: IStyleFunctionOrObject<IPivotStyleProps, IPivotStyles> = {
  itemContainer: {
    display: 'flex',
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
  },
};

const Home = () => {
  const onDeploySmall = useCallback(() => {}, []);
  const onDeployMedium = useCallback(() => {}, []);
  const onDeployLarge = useCallback(() => {}, []);
  return (
    <Page>
      <h1>Ethereum node deployment templates</h1>
      <aside>
        <p>Not all Ethereum nodes are created equal</p>
        <p>
          Pick the &quot;T shirt size&quot; template that&apos;s right for you!
        </p>
      </aside>
      <Pivot aria-label="Node sizing pivot" styles={pivotStyles}>
        <PivotItem headerText="Small" className={styles.pivotItem}>
          <Text variant="medium" nowrap block>
            Pick this template for small deployments. Ideal for hobbyists,
            Ethereum power users, learning, etc... Perfect for when you
            don&apos;t really need to scale on demand
          </Text>
          <Image src={BYONP_S} alt="Small" />
          <PrimaryButton text="Deploy Azure template" onClick={onDeploySmall} />
        </PivotItem>
        <PivotItem headerText="Medium" className={styles.pivotItem}>
          <Text variant="medium">
            Pick this template for medium deployments. When you&apos;re unsure
            if you need the large or small deployments but could see it going
            either way. The medium size is a fine choice for most scenario
            because you can always cut down to a single node if that&apos;s all
            you need
          </Text>
          <Image src={BYONP_M} alt="Medium" />
          <PrimaryButton
            text="Deploy Azure template"
            onClick={onDeployMedium}
          />
        </PivotItem>
        <PivotItem headerText="Large" className={styles.pivotItem}>
          <Text variant="medium" nowrap block>
            Pick this template for large deployments. Pick this when you know
            you will need to scale at some point. Or if you are a Kubernetes
            enthusiast
          </Text>
          <Image src={BYONP_L} alt="Large" />
          <PrimaryButton text="Deploy Azure template" onClick={onDeployLarge} />
        </PivotItem>
      </Pivot>
    </Page>
  );
};

export default Home;
