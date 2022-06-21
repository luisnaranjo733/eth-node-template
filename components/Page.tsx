import { PropsWithChildren } from 'react';
import styles from '../styles/page.module.scss';

type PageProps = PropsWithChildren<{}>;
const Page = ({ children }: PageProps) => {
  return <main className={styles.main}>{children}</main>;
};

export default Page;
